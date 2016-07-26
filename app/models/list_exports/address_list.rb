module ListExports
  class AddressList < Base

    def columns
      [
        :last_name,
        :first_name,
        :name_affix,
        :postal_address_with_name_surrounding,
        :postal_address,
        :cached_localized_postal_address_updated_at,
        :postal_address_street,
        :postal_address_street_name,
        :postal_address_street_number,
        :postal_address_postal_code,
        :postal_address_town,
        :postal_address_state,
        :postal_address_country,
        :postal_address_country_code,
        :postal_address_country_code_3_letters,
        :personal_title_and_name,
        :personal_title,
        :address_label_text_above_name,
        :address_label_text_below_name,
        :address_label_text_before_name,
        :address_label_text_after_name,
        :function_in_list_export_group
      ]
    end

  end
end