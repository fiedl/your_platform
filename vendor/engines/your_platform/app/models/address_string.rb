class AddressString < String

  def initialize str
    super str
  end
  
  def latitude ;      geo_information :lat           end
  def longitude ;     geo_information :lng           end
  def country ;       geo_information :country       end
  def country_code ;  geo_information :country_code  end
  def city ;          geo_information :city          end
  def postal_code ;   geo_information :postal_code   end
  
  def plz
    return postal_code if country_code == "DE"
    return nil
  end

  def geo_information( key )

    # cache the geo information object
    @geo_information ||= geo_information_from_geocoder

    # German plz
    return self.plz if key == :plz

    # latitude and longitude apparently have been renamed
    key = :latitude if key == :lat
    key = :longitude if key == :lng

    # return the requested geo information
    @geo_information.send key if @geo_information
  end

  private

  def geo_information_from_geocoder
    Geocoder.search( self ).first
  end

end
