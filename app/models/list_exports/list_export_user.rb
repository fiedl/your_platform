module ListExports
  class ListExportUser < User

    attr_accessor :list_export_group

    def personal_title_and_name
      "#{personal_title} #{name}".strip
    end
    def name_affix_without_deceased_symbol
      name_affix.gsub(" (✟)", "")
    end

    # Name list
    #
    attr_accessor :member_since

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
    def localized_date_of_death
      date_of_death # which is localized already
    end
    def age_at_date_of_death
      ((date_of_death.to_date - date_of_birth) / 365.25).to_int if date_of_death and date_of_birth
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
    def postal_address_postal_code_and_town
      if str = address_label.postal_address
        str.gsub!(postal_address_street_with_number.to_s, ' ') if postal_address_street_with_number.to_s.present?
        str.gsub!("\n" + postal_address_second_address_line.to_s, ' ' ) if postal_address_second_address_line.to_s.present?
        str.gsub!(/\n#{postal_address_country.to_s}\z/m, ' ') if postal_address_country.to_s.present?
        str.gsub!("\n", '')
        str.gsub!("  ", " ")
        str = str.strip
        str
      end
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

    # User-group relation
    #
    # Some exports need information about the relation of the user
    # and the group that is exported, for example the date of the user
    # joining the group, or the role the user plays for that group.
    #
    def function_in_list_export_group
      function_group_in_list_export_group.try(:extensive_name)
    end
    def function_group_in_list_export_group
      (self.direct_groups & list_export_group.descendant_groups).first
    end


    def cache_key
      # Otherwise the cached information of the user won't be used.
      super.gsub('list_export_users/', 'users/')
    end
  end
end
