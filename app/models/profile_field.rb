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
    Gmaps4rails.geocode( self.value ).first[ :lat ]
  end

  def longitude
    Gmaps4rails.geocode( self.value ).first[ :lng ]
  end

  

end

