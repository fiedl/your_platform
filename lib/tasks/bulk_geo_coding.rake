
require 'colored'

namespace :bulk_geo_coding do

  desc "Geocode Address Fields"
  task geocode_address_fields: :environment do
    STDOUT.sync = true

    @bulk_geo_coder = BulkGeoCoder.new( bulk_size: 10, wait_seconds: 2 )
    @bulk_geo_coder.geocode_address_fields

  end

  desc "Run all tasks"
  task :all => [
                :geocode_address_fields
               ]

end

class BulkGeoCoder

  def initialize( args )
    @bulk_size = args[:bulk_size]
    @bulk_size ||= 50
    @counter = 0
    @wait_seconds = args[:wait_seconds]
    @wait_seconds ||= 10

    @failed = []
  end

  def geocode_address_fields
    @counter = 0
    address_fields.each do |address_field|
      manage_bulk do
        geocode_address_field_if_ungeocoded( address_field )
      end
    end

    print "\n"
    print "processed #{@counter} new address fields.\n".green
    
    if @failed.count > 0
      print "\n"
      print "Failed to geocode:\n".red
      p @failed
    end

  end

  def address_fields
    ProfileField.where( type: "ProfileFieldTypes::Address" )
  end

  def geocode_address_field_if_ungeocoded( address_field )
#    if address_field.geocoded?
    if address_field_geocoded?( address_field )
      print "."
      @counter -=1 # these are free
    else
      #address_field.geocode
      geocode_address_field( address_field )
      if address_field.country_code
        print ".".green
      else
        print ".".red
        @failed << { title: address_field.profileable.title, address: address_field.value, 
          profile_field_id: address_field.id }
      end
    end
  end

  def address_field_geocoded?( address_field )
    (not GeoLocation.find_by_address( address_field.value ).nil?) && 
      (not GeoLocation.find_by_address( address_field.value ).country_code.nil?)
  end

  def geocode_address_field( address_field )
    # this will find_or_create the associated geo_location
    # and thereby query the geo API
    address_field.geo_location.geocode
  end

  def manage_bulk( &block )
    @counter += 1

    # give it some time after each bulk. Otherwise, the API
    # will close the connection.
    sleep @wait_seconds if @counter.modulo(@bulk_size) == 0

    yield
  end

end


# Apparently, I can't reopen the class from here.
# This does not work:

#module ProfileFieldTypes
#  class Address
#
#    def geocoded?
#      not GeoLocation.find_by_address( value ).nil?
#    end
#
#    def geocode
#      # this will find_or_create the associated geo_location
#      # and thereby query the geo API
#      geo_location
#    end
#
#  end
#end
