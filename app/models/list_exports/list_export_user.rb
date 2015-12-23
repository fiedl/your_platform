module ListExports
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
    def postal_address_street_with_number
      postal_address_field_or_first_address_field.try(:street_with_number)
    end
    def postal_address_second_address_line
      postal_address_field_or_first_address_field.try(:second_address_line)
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
      postal_address_field_or_first_address_field.try(:country_if_not_default)
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
end
