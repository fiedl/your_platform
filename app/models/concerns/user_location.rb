concern :UserLocation do

  included do
    has_one :location, as: :object
  end

  def set_current_location(attributes = {longitude: nil, latitude: nil})
    (self.location || self.create_location).update_attributes(attributes)
  end

  # user.neadby_users(within_meters: 100)
  #
  def nearby_users(options = {})
    self.location.nearby_users(options)
  end

  def nearby_addresses(options = {})
    self.location.nearby_addresses(options)
  end

end