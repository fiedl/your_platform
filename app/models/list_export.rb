require 'csv'

# This class helps to export data to CSV, XLS and possibly others.
#
# Example:
#
#     class PeopleController
#       def index
#         # ...
#         format.xls do
#           send_data ListExport.new(@people, :birthday_list).to_xls
#         end
#       end
#     end
#
# The following ressources might be helpful.
#
#   * https://github.com/splendeo/to_xls
#   * https://github.com/zdavatz/spreadsheet
#   * Formatting xls: http://scm.ywesee.com/?p=spreadsheet/.git;a=blob;f=lib/spreadsheet/format.rb
#   * to_xls gem example: http://stackoverflow.com/questions/15600987/
#
class ListExport
  attr_accessor :data, :preset, :csv_options

  def initialize(initial_data, initial_preset = nil)
    @data = initial_data; @preset = initial_preset
    @csv_options =  { col_sep: ';', quote_char: '"' }
    raise_error_if_data_is_not_valid
    @data = processed_data
    @data = sorted_data
  end

  def columns
    case preset.to_s
    when 'phone_list'
      [:last_name, :first_name, :name_affix, :phone_label, :phone_number]
      # One row per phone number, not per user. See `#processed_data`.
    when 'member_development'
      [:last_name, :first_name, :name_affix, :localized_date_of_birth, :date_of_death] + (@leaf_group_names - [nil])
    when 'join_statistics', 'join_and_persist_statistics'
      [:group] + ((Date.today.year - 25)..(Date.today.year)).to_a.reverse.map(&:to_s)
    else
      raise RuntimeError, "The list '#{preset.to_s}' is not defined."
    end
  end

  def headers
    columns.collect do |column|
      if column.kind_of? Symbol
        I18n.translate column.to_s.gsub('cached_', '').gsub('localized_', '')
      elsif column.to_s.include?("_") && column.respond_to?(:humanize)
        column.humanize
      else
        column
      end
    end
  end

  def processed_data
    if preset.to_s.in?(['birthday_list', 'address_list', 'dpag_internetmarke', 'phone_list']) && @data.kind_of?(Group)
      # To be able to generate lists from Groups as well as search results, these presets expect
      # an Array of Users as data. If a Group is given instead, just take the group members as data.
      #
      @data = @data.members
    end

    # Make the extended methods available that are defined below.
    #
    if @data.respond_to?(:first) && @data.first.kind_of?(User)
      @data = @data.collect { |user| user.becomes(ListExportUser) }
    end

    case preset.to_s
    when 'phone_list'
      #
      # For the phone_list, one row represents one phone number of a user,
      # not a user. I.e. there can be serveral rows per user.
      #
      data.collect { |user|
        user.phone_profile_fields.collect { |phone_field| {
          :last_name          => user.last_name,
          :first_name         => user.first_name,
          :name_affix         => user.name_affix,
          :phone_label        => phone_field.label,
          :phone_number       => phone_field.value
        } }
      }.flatten
    when 'member_development'
      #
      # From data being a Group, this generates one line per user. Several columns are
      # created based on the leaf groups of the given Group.
      #
      @group = @data
      @group = @group.becomes(ListExportGroup)
      @leaf_groups = @group.leaf_groups
      # FIXME: The leaf groups should not return any officer group. Make this fix unneccessary:
      @leaf_groups -= @group.descendant_groups.where(name: ['officers', 'Amtsträger'])
      @leaf_groups -= @group.descendant_groups.where(name: ['attendees', 'Teilnehmer', 'contact_people', 'Ansprechpartner'])
      @leaf_group_names = @leaf_groups.map(&:name)
      @leaf_group_ids = @leaf_groups.collect { |group| group.id }
      # /FIXME - please uncomment:
      #@leaf_group_names = @leaf_groups.pluck(:name)
      #@leaf_group_ids = @leaf_groups.pluck(:id }

      @group.members.collect do |user|
        user = user.becomes(ListExportUser)
        row = {
          :last_name                      => user.last_name,
          :first_name                     => user.first_name,
          :name_affix                     => user.name_affix,
          :localized_date_of_birth        => user.localized_date_of_birth,
          :date_of_death                  => user.date_of_death
        }
        @leaf_groups.each do |leaf_group|
          membership = user.links_as_child_for_groups.where(ancestor_id: leaf_group.id).first
          date = membership.try(:valid_from).try(:to_date)
          localized_date = I18n.localize(date) if date
          row[leaf_group.name] = (localized_date || '')
        end
        row
      end
    when 'join_statistics', 'join_and_persist_statistics'
      #
      # From a list of groups, this creates one row per group.
      # The columns count the number of memberships valid from the year given by the column.
      #
      # For the 'join_and_persist_statistics', only memberships are counted
      # that are still valid, i.e. still persist.
      #
      #            2014   2013   2012   2011   ...
      #  group1     24     22     25     28    ...
      #  group2     31     28     27     32    ...
      #   ...
      #
      if @data.kind_of? Group
        @groups = [@data] + @data.child_groups
        if preset.to_s == 'join_and_persist_statistics'
          @groups = @groups.select { |g| g.members.count > 0 }
        end
      elsif @data.kind_of? Array
        @groups = @data
      end
      @groups.collect do |group|
        row = {}
        columns.each do |column|
          row[column] = if column.to_s.to_i.to_s.length == 4
            year = column.to_i
            memberships = []
            if preset.to_s == 'join_statistics'
              memberships = group.memberships.with_past
            elsif preset.to_s == 'join_and_persist_statistics'
              memberships = group.memberships
            else
              raise RuntimeError, 'attention, case not handled, yet!'
            end
            memberships = memberships.where(valid_from: "#{year}-01-01".to_datetime..("#{year + 1}-01-01".to_datetime - 1.second))
            memberships.count # TODO: Refactor this when allowing multiple dag links between two nodes.
          elsif column == :group
            group.name_with_corporation
          end
        end
        row
      end
    else
      data
    end
  end

  def sorted_data
    case preset.to_s
    when 'address_list', 'name_list'
      data.sort_by do |user|
        user.last_name + user.first_name
      end
    when 'phone_list', 'email_list'
      data.sort_by do |user_hash|
        user_hash[:last_name] + user_hash[:first_name]
      end
    else
      data
    end
  end

  def raise_error_if_data_is_not_valid
    case preset.to_s
    when 'birthday_list', 'address_list', 'dpag_internetmarke', 'phone_list', 'email_list', 'name_list'
      data.kind_of?(Group) || data.first.kind_of?(User) || raise(RuntimeError, "Expecing Group or list of Users as data in ListExport with the preset '#{preset}'.")
    when 'member_development'
      data.kind_of?(Group) || raise(RuntimeError, 'The member_development list can only be generated for a Group, not an Array of Users.')
    end
  end

  def to_csv
    CSV.generate(csv_options) do |csv|
      csv << headers
      data.each do |row|
        csv << columns.collect do |column_name|
          if row.respond_to? :values
            row[column_name]
          elsif row.respond_to? column_name
            row.try(:send, column_name)
          else
            raise RuntimeError, "Don't know how to access the given attribute or value. Trying to access '#{column_name}' on '#{row}'."
          end
        end
      end
    end
  end

  def to_xls
    header_format = {weight: 'bold'}
    @data = @data.collect { |hash| HashWrapper.new(hash) } if @data.first.kind_of? Hash
    @data.to_xls(columns: columns, headers: headers, header_format: header_format)
  end

  def to_html
    ("
      <table class='datatable joining statistics'>
        <thead>
          <tr>
            " + headers.collect { |header| "<th>#{header}</th>" }.join + "
          </tr>
        </thead>
        <tbody>
          " + data.collect { |row|
            "<tr>" + row.values.collect { |v| "<td>#{v}</td>" }.join + "</tr>"
          }.join + "
        </tbody>
      </table>
    ").html_safe
  end

  def to_a
    @data
  end

  def to_s
    to_csv
  end

  private

  def helpers
    ActionController::Base.helpers
  end
  def method_missing(*args, &block)
    helpers.send(*args, &block)
  end
end

class HashWrapper
  def initialize(hash)
    @hash = hash
  end

  def get(column_name)
    @hash[column_name.to_s] || @hash[column_name.to_sym]
  end

  # This is a workaround for the to_xls gem, which requires to access the attributes
  # by method in order to write the columns in the correct order.
  #
  def method_missing(method_name, *args, &block)
    get(method_name)
  end
end

# TODO: Refactor this:
#   Whenever it makes sense, these methods should live inside the regular User class.
#   But this should be done after introducing the new model caching mechanism.
#
require 'user'
class ListExportUser < User

  def personal_title_and_name
    "#{personal_title} #{name}".strip
  end

  # Birthday, Date of Birth, Date of Death
  #
  def current_age
    age
  end
  def localized_birthday_this_year
    I18n.localize birthday_this_year if birthday_this_year
  end
  def localized_date_of_birth
    I18n.localize date_of_birth if date_of_birth
  end
  def localized_next_birthday
    I18n.localize next_birthday if next_birthday
  end

  # Address
  #
  def postal_address_with_name_surrounding
    address_label.postal_address_with_name_surrounding
  end
  def cached_postal_address_updated_at
    postal_address_updated_at
  end
  def cached_localized_postal_address_updated_at
    I18n.localize cached_postal_address_updated_at if cached_postal_address_updated_at
  end
  def postal_address_street
    address_label.street
  end
  def postal_address_street_name
    postal_address_street.split(" ")[0..-2].join(" ") if postal_address_street.present?
  end
  def postal_address_street_number
    postal_address_street.split(" ").last if postal_address_street.present?
  end
  def postal_address_postal_code
    address_label.postal_code
  end
  def postal_address_town
    address_label.city
  end
  def postal_address_state
    address_label.state
  end
  def postal_address_country
    address_label.country
  end
  def postal_address_country_code
    address_label.country_code.try(:upcase)
  end
  def postal_address_country_code_3_letters
    address_label.country_code_with_3_letters
  end
  def address_label_text_above_name
    address_label.text_above_name
  end
  def address_label_text_below_name
    address_label.text_below_name
  end
  def address_label_text_before_name
    address_label.name_prefix
  end
  def address_label_text_after_name
    address_label.name_suffix
  end
  def dpag_postal_address_type
    "HOUSE"
  end

  def cache_key
    # Otherwise the cached information of the user won't be used.
    super.gsub('list_export_users/', 'users/')
  end
end

class ListExportGroup < Group
end