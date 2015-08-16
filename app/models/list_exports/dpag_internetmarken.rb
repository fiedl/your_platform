module ListExports
  class DpagInternetmarken < Base
    
    def columns
      [
        :personal_title_and_name,
        :text_below_name,
        :postal_address_street_name,
        :postal_address_street_number,
        :postal_address_postal_code,
        :postal_address_town,
        :postal_address_country_code_3_letters,
        :dpag_postal_address_type
      ]
    end
    
    def headers
      %w(NAME ZUSATZ STRASSE NUMMER PLZ STADT LAND ADRESS_TYP)
    end
    
    # Originally, `data` is an Array of Users. We need to insert the sender information
    # as first entry.
    #
    def data
      [sender_row] + super
    end
    
    def sender_row
      {
        :name => "Bitte eintragen: Absender-Name",
        :personal_title_and_name => "Bitte eintragen: Absender-Name",
        :text_below_name => "",
        :postal_address_street_name => "Absender-Straße",
        :postal_address_street_number => "Absender-Hausnummer",
        :postal_address_postal_code => "Absender-PLZ",
        :postal_address_country => "Absender-Land",
        :dpag_postal_address_type => "HOUSE"
      }
    end
    
  end
end