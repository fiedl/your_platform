
require 'colored'

namespace :bulk_geo_coding do

  desc "Geocode Address Fields"
  task geocode_address_fields: :environment do
    STDOUT.sync = true

    #Geocoder::Configuration.always_raise << Geocoder::OverQueryLimitError
    #Geocoder::Configuration.always_raise = :all

    @bulk_geo_coder = BulkGeoCoder.new( bulk_size: 50, wait_seconds: 10 )
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
    @quota_counter = 0
    @wait_seconds = args[:wait_seconds]
    @wait_seconds ||= 10

    @failed = []
    @invalid = []
  end

  def geocode_address_fields
    @counter = 0
    address_fields.each do |address_field|
      manage_bulk do
        geocode_address_field_if_ungeocoded( address_field )

        if @quota_counter > 20
          print "\n" + "Apparently you have hit the query quota. Please try again tomorrow.".red
          print "\n"
          print_stats
          return
        end
      end
    end

    print_stats
  end

  def print_stats
    print "\n"
    print "processed #{@counter} new address fields.\n".green
    
    if @invalid.count > 0
      print "\n"
      print "#{@invalid.count} invalid addresses:\n".yellow
      p @invalid
    end

    if @failed.count > 0
      print "\n"
      print "#{@failed.count} addresses failed to geocode:\n".red
      p @failed
    end

  end

  def address_fields
    ProfileField.where( type: "ProfileFieldTypes::Address" )
  end

  def geocode_address_field_if_ungeocoded( address_field )
    if address_field.geocoded?
      print "."
      @counter -=1 # these are free
    else
      address_field.geocode
      if address_field.geocoded? && address_field.country_code.present?
        print ".".green # everything fine
        @quota_counter = 0
      elsif address_field.geocoded? && address_field.country_code.nil?
        print ".".yellow # invalid address
        @quota_counter = 0
        @invalid << { title: address_field.profileable.title, address: address_field.value, 
          profile_field_id: address_field.id }
      else
        p address_field
        print ".".red # query error
        @quota_counter += 1        
        @failed << { title: address_field.profileable.title, address: address_field.value, 
          profile_field_id: address_field.id }
      end
    end
  end

  def manage_bulk( &block )
    @counter += 1

    # give it some time after each bulk. Otherwise, the API
    # will close the connection.
    sleep @wait_seconds if @counter.modulo(@bulk_size) == 0

    yield
  end

end


