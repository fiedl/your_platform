class ProfileField < ActiveRecord::Base
  
  attr_accessible        :user_id, :label, :type, :value
  
  belongs_to             :user

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

  def latitude
    geo_information :lat
  end

  def longitude
    geo_information :lng
  end

  def gmaps
    true
  end

  def geo_information( key )
    @geo_information = geo_information_from_gmaps unless @geo_information
    @geo_information[ key ] if @geo_information
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

