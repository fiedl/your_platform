concern :CorporationLocation do

  included do
    has_one :location, as: :object

    def location
      super || extract_location_from_address
    end
  end

  def extract_location_from_address
    if geo_location = self.address_profile_fields.first.try(:geo_location)
      self.create_location(longitude: geo_location.longitude, latitude: geo_location.latitude)
    end
    return self.location
  end

end