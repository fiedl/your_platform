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
  
  
  
  
  
  
  # 
  
  def csv_options
    { col_sep: ';', quote_char: '"' }
  end
  
  
end
