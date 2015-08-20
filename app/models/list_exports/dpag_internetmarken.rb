module ListExports
  
  # This class produces a list export for the DPAG-Internetmarken webservice.
  # 
  # See also: https://www.deutschepost.de/de/i/internetmarke-porto-drucken.html
  # Feature Request: https://github.com/fiedl/wingolfsplattform/issues/67
  # 
  # The encoding of the csv export has to be ISO 8859-1 (Western Latin 1).
  # The country codes need to be in ISO 3166-1-Alpha-3 (3-letter codes).
  # The first row describes the sender line.
  #
  # The result looks like this:
  #
  #     NAME;ZUSATZ;STRASSE;NUMMER;PLZ;STADT;LAND;ADRESS_TYP
  #     Bitte eintragen: Absender-Name;;Absender-Straße;Absender-Hausnummer;Absender-PLZ;Absender-Stadt;DEU;HOUSE
  #     Dr. Jonathan Doe;c./o. Foo Bar;Pariser Platz;1;10117;Berlin;DEU;HOUSE
  #
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
        :postal_address_town => "Absender-Stadt",
        :postal_address_country => "Absender-Land",
        :postal_address_country_code_3_letters => "DEU",
        :dpag_postal_address_type => "HOUSE"
      }
    end
    
    # The dpag software does not recognize "" as empty value. Thus,
    # we need to replace those.
    #
    def to_csv
      super.gsub(';"";', ';;')
    end
      
  end
end