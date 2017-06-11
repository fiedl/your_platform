class Location < ActiveRecord::Base
  belongs_to :object, polymorphic: true

  # location.neadby_users(within_meters: 100)
  #
  def nearby_users(options = {})
    options[:within_meters] ||= 100
    Location.where(object_type: 'User', updated_at: 1.day.ago..Time.zone.now).select { |other_location|
      Geocoder::Calculations.distance_between([self.latitude, self.longitude], [other_location.latitude, other_location.longitude]) <= (options[:within_meters] / 1000)
    }.map(&:object) - [object]
  end

  def nearby_addresses(options = {})
    options[:within_meters] ||= 5000
    geo_locations = GeoLocation.near([self.latitude, self.longitude], options[:within_meters] / 1000)
    addresses = ProfileField.where value: geo_locations.map(&:address), type: "ProfileFields::Address"
    addresses = addresses.select do |address|
      address.profileable_alive_and_member?
    end
  end

end
