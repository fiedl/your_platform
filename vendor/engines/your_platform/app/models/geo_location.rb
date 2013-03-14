class GeoLocation < ActiveRecord::Base
  attr_accessible :address #, :city, :country, :country_code, :latitude, :longitude, :postal_code


  # When to perform geocoding queries (to google)
  # ==========================================================================================

  after_validation :geocode, :if => [ 'address_changed?', 'latitude.nil?' ]
  after_find :geocode_and_save, :if => 'latitude.nil?'


  # What to do when performing a geocoding query (to google)
  # ==========================================================================================

  geocoded_by :address do |geo_location, geo_query_results|
    result = geo_query_results.first
    if result
      geo_location.latitude = result.latitude
      geo_location.longitude = result.longitude
      geo_location.city = result.city
      geo_location.country = result.country
      geo_location.country_code = result.country_code
      geo_location.postal_code = result.postal_code
    end
    self
  end
  
  # Perform geocode query and save the record.
  # This is needed after finding a record where no geocode query has been done, yet.
  #
  def geocode_and_save
    geocode
    save
  end


  # Finder Methods
  # ==========================================================================================

  # Find a geo_location object by address string. 
  # If the address already exists in the database, return the object from
  # the database. Otherwise, create a new database entry for the address
  # and perform a geocoding query.
  #
  # This method is already defined be ActiveRecord.
  #
  # def self.find_or_create_by_address( address_string )
  # end


  # Country Specific Methods
  # ==========================================================================================

  # This method returns true if the location is in Europe.
  #
  def in_europe?
    country_code.in?(%w(AD AL AT BA BE BG BY CH CY CZ DE DK EE ES FI FO FR GG GI GR GB HR HU IE IM IS IT JE LI LT LU LV MC MD\
 MK MT NL NO PL PT RO RU SE SI SJ SK SM TR UA UK VA YU))
  end

  # The following method is a country-specific accessor to the the German
  # Postleitzahl (PLZ). If returns the German postal code if the
  # address is in Germany. Otherwise, it returns nil.
  #
  def plz
    postal_code if country_code == "DE"
  end

end
