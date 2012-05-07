class ProfileField < ActiveRecord::Base
  
  attr_accessible        :user_id, :label, :type, :value
  
  belongs_to             :profileable, polymorphic: true

end

class Custom < ProfileField

end

class Organisation < ProfileField

end

class Email < ProfileField

end

class Address < ProfileField

  # Google Maps integration
  # see: http://rubydoc.info/gems/gmaps4rails/
  acts_as_gmappable 

  def gmaps4rails_address
    self.value
  end

  def gmaps
    true
  end

  # TODO: resolve redundancy with class AddressString


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
    @geo_information = geo_information_from_gmaps unless @geo_information
    @geo_information[ key ] if @geo_information
  end

  def bv
    address= AddressString.new self.value
    return Bv.by_address( address )
  end

  private

  def geo_information_from_gmaps
    begin
      Gmaps4rails.geocode( self.gmaps4rails_address ).first
    rescue
      return nil
      # Wenn keine Verbindung zu GoogleMaps besteht, wird hier ein Fehler auftreten,
      # der die Anwendung jedoch nicht beenden sollte. 
    end
  end

end

