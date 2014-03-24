# This module manages the csv export for groups.
#
module GroupMixins::Csv

  extend ActiveSupport::Concern

  included do
  end
  
  module ClassMethods
  end
  
  # This method returns a string containing comma separated 
  # members of the group.
  #
  # Depending on the given parameter, the set of columns
  # is chosen.
  #
  # @param column_configuration [String] the type of list that
  #   is expected to be returned. This can be one of the following:
  #
  #   'name_list'       (Default)
  #   'birthday_list'
  #   'address_list'
  #   'phone_list'
  #   'email_list'
  # 
  def members_to_csv(column_configuration)
    case column_configuration
      when 'birthday_list' then members_birthdays_to_csv
      when 'address_list' then members_addresses_to_csv
      else members_names_to_csv
    end
  end
  
  def members_names_to_csv
    CSV.generate(csv_options) do |csv|
      csv << [
        I18n.t(:last_name),
        I18n.t(:first_name),
        '',
        '',
        I18n.t(:personal_title),
        I18n.t(:academic_degree)
      ]
      self.members.each do |member|
        csv << [
          member.last_name,
          member.first_name,
          member.title.gsub(member.name, '').strip,
          member.title,
          member.personal_title,
          member.academic_degree
        ]
      end
    end
  end
  
  def members_birthdays_to_csv
    CSV.generate(csv_options) do |csv|
      csv << [
        I18n.t(:last_name),
        I18n.t(:first_name),
        '',
        I18n.t(:birthday),
        I18n.t(:date_of_birth),
        I18n.t(:current_age)
      ]
      self.members.sort_by do |member|
        member.date_of_birth.try(:strftime, "%m-%d") || ''
      end.each do |member|
        csv << [
          member.last_name,
          member.first_name,
          member.title.gsub(member.name, '').strip,
          member.date_of_birth.nil? ? '' : I18n.localize(member.date_of_birth.change(:year => Time.zone.now.year)), 
          member.date_of_birth.nil? ? '' : I18n.localize(member.date_of_birth), 
          member.date_of_birth.nil? ? '' : member.age
        ]
      end
    end
  end
  
  def members_addresses_to_csv
    CSV.generate(csv_options) do |csv|
      csv << [
        I18n.t(:last_name),
        I18n.t(:first_name),
        '',
        I18n.t(:address),
        I18n.t(:address),
        I18n.t(:last_updated_at),
        I18n.t(:personal_title),
        I18n.t(:text_above_name),
        I18n.t(:text_below_name),
        I18n.t(:name_prefix),
        I18n.t(:name_suffix)
      ]
      self.members.each do |member|
        address_field = member.postal_address_field_or_first_address_field
        if address_field.updated_at.to_date > "2014-02-28".to_date 
          # if the date is earlier, the date is actually the date
          # of the data migration and should not be shown.
          updated_at = I18n.localize(address_field.updated_at.to_date) 
        end
        csv << [
          member.last_name,
          member.first_name,
          member.title.gsub(member.name, '').strip,
          member.postal_address_with_name_surrounding,
          address_field.value,
          updated_at,
          member.personal_title,
          member.text_above_name,
          member.text_below_name,
          member.name_prefix,
          member.name_suffix
        ]
      end
    end
  end
  
  def csv_options
    { col_sep: ';', quote_char: '"' }
  end
  
  
end