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
      when 'phone_list' then members_phone_numbers_to_csv
      when 'email_list' then members_emails_to_csv
      when 'member_development' then member_development_to_csv
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
        I18n.t(:current_age),
        'BV' # Wingolf Hack. TODO: Move to wingolfsplattform.
      ]
      self.members.sort_by do |member|
        member.cached_date_of_birth.try(:strftime, "%m-%d") || ''
      end.each do |member|
        csv << [
          member.last_name,
          member.first_name,
          member.cached_name_suffix,  
          member.cached_date_of_birth.nil? ? '' : I18n.localize(member.cached_birthday_this_year), 
          member.cached_date_of_birth.nil? ? '' : I18n.localize(member.cached_date_of_birth), 
          member.cached_date_of_birth.nil? ? '' : member.cached_age,
          member.bv.try(:token) # Wingolf Hack. TODO: Move to wingolfsplattform.
        ]
      end
    end
  end
  
  def members_addresses_to_csv
    
    # TODO: Add the streat as a separate column.
    # This was requested at the meeting at Gernsbach, Jun 2014.
    
    CSV.generate(csv_options) do |csv|
      csv << [
        I18n.t(:last_name),
        I18n.t(:first_name),
        '',
        I18n.t(:address),
        I18n.t(:address),
        I18n.t(:last_updated_at),
        I18n.t(:postal_code),
        I18n.t(:town),
        I18n.t(:country),
        I18n.t(:country_code),
        I18n.t(:personal_title),
        I18n.t(:text_above_name),
        I18n.t(:text_below_name),
        I18n.t(:name_prefix),
        I18n.t(:name_suffix)
      ]
      self.members.order(:last_name).each do |member|
        address_field = member.postal_address_field_or_first_address_field
        geo = address_field.geo_location
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
          geo.postal_code,
          geo.city,
          geo.country,
          geo.country_code,
          member.personal_title,
          member.text_above_name,
          member.text_below_name,
          member.name_prefix,
          member.name_suffix
        ]
      end
    end
  end
  
  def members_phone_numbers_to_csv
    CSV.generate(csv_options) do |csv|
      csv << [
        I18n.t(:last_name),
        I18n.t(:first_name),
        '',
        I18n.t('profile_field.label'),
        I18n.t(:phone_number)
      ]
      self.members.order(:last_name).each do |member|
        member.phone_profile_fields.each do |phone_field|
          csv << [
            member.last_name,
            member.first_name,
            member.title.gsub(member.name, '').strip,
            phone_field.label,
            phone_field.value
          ]
        end
      end
    end
  end
  
  def members_emails_to_csv
    CSV.generate(csv_options) do |csv|
      csv << [
        I18n.t(:last_name),
        I18n.t(:first_name),
        '',
        I18n.t('profile_field.label'),
        I18n.t(:email_address)
      ]
      self.members.order(:last_name).each do |member|
        member.profile_fields.where(type: 'ProfileFieldTypes::Email').each do |email_field|
          csv << [
            member.last_name,
            member.first_name,
            member.title.gsub(member.name, '').strip,
            email_field.label,
            email_field.value
          ]
        end
      end
    end
  end
  
  # Diese Methode stellt Informationen zur Mitgliederbewegung in einem CSV-Format
  # zusammen. Hierfür werden die Gruppenmitglieder mit ihren wichtigsten Daten
  # sowie ihren jeweiligen Eintrittsdaten der Statusgruppen aufgeführt.
  # 
  def member_development_to_csv
    status_groups = self.cached_leaf_groups

    # FIXME: The leaf groups should not return any officer group.
    # Make this fix unneccessary:
    status_groups = status_groups - self.descendant_groups.where(name: ['officers', 'Amtsträger'])

    status_group_names = status_groups.collect { |group| group.name }
    status_group_ids = status_groups.collect { |group| group.id }
    
    CSV.generate(csv_options) do |csv|
      csv << [
        I18n.t(:last_name),
        I18n.t(:first_name),
        '',
        I18n.t(:date_of_birth),
        I18n.t(:date_of_death)
      ] + status_group_names
      self.members.each do |member|
        links = member.links_as_child_for_groups
        status_group_membership_dates = status_groups.collect do |status_group|
          link = links.select { |link| link.ancestor_id == status_group.id }.first
          datetime = link.try(:valid_from)
          date = datetime.try(:to_date)
          localized_date = I18n.localize(date) if date
          localized_date || ''
        end
        
        csv << [
          member.last_name,
          member.first_name,
          member.title.gsub(member.name, '').strip,
          member.date_of_birth.nil? ? '' : I18n.localize(member.date_of_birth),
          member.date_of_death || ''
        ] + status_group_membership_dates
      end
    end
  end
  
  def csv_options
    { col_sep: ';', quote_char: '"' }
  end
  
  
end
