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

end
