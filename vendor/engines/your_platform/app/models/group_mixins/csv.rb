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
