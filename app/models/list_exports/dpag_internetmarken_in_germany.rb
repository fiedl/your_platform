module ListExports
  class DpagInternetmarkenInGermany < DpagInternetmarken
    
    # Filter the addresses such that only German addresses are included.
    #
    def data
      [sender_row] + super.select do |data_row|
        data_row.kind_of?(User) && 
        data_row.becomes(ListExportUser).postal_address_country_code.upcase == 'DE'
      end
    end

  end
end