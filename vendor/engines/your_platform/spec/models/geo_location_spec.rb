require 'spec_helper'

describe GeoLocation do

  # In order to test this without querying the real geocoding API of google, 
  # there are stubs in spec/support/geocoder/stubs.rb.

  before do 
    @address_string = "Pariser Platz 1\n 10117 Berlin"
    @geo_location = GeoLocation.new( address: @address_string )
  end


  # Geocoding Queries
  # ==========================================================================================

  describe "#geocode" do
    subject { @geo_location.geocode }
    it "should fill the geo information" do
      @geo_location.address.should == @address_string
      @geo_location.country_code.should == nil
      subject
      @geo_location.city.should == "Berlin"
      @geo_location.country.should == "Germany"
      @geo_location.country_code.should == "DE"
      @geo_location.latitude.should == 52.5163
      @geo_location.longitude.should == 13.3778
      @geo_location.postal_code.should == "10117"
      @geo_location.plz.should == "10117"
      @geo_location.address.should == @address_string
    end
    it "should set the queried_at attribute" do
      @geo_location.queried_at.should == nil
      subject
      @geo_location.queried_at.should be_kind_of Time
    end
  end

  describe "#geocode_and_save" do
    subject { @geo_location.geocode_and_save }
    it "should fill the geo information" do
      @geo_location.country_code.should == nil
      subject
      @geo_location.country_code.should == "DE"
    end
    it "should save the record" do
      @geo_location.id.should == nil
      subject
      @geo_location.id.should_not == nil
    end
  end

  describe "#geocoded?" do
    subject { @geo_location.geocoded? }
    describe "before the query" do
      it { should == false }
    end
    describe "after the query" do
      before { @geo_location.geocode }
      it { should == true }
    end
    describe "after reloading the object" do
      before { @geo_location.geocode_and_save }
      subject { GeoLocation.find_by_address(@geo_location.address).geocoded? }
      it "should persist" do
        subject.should == true
      end
    end
  end


  # Finder Methods
  # ==========================================================================================

  describe ".find_or_create_by_address" do
    subject { GeoLocation.find_or_create_by_address(@address_string) }
    describe "for an existing record" do
      before { @geo_location = GeoLocation.create( address: @address_string ) }
      it "should find the existing one" do
        subject.should == @geo_location
      end
    end
    describe "for no record existing" do
      it "should create one" do
        GeoLocation.find_by_address(@address_string).should == nil
        subject.should be_kind_of GeoLocation
        subject.id.should_not == nil
      end
    end
  end

  
  # Country Specific Methods
  # ==========================================================================================

  describe "#in_europe?" do
    subject { @geo_location.in_europe? }
    describe "for an address in europe" do
      before { @geo_location = GeoLocation.new; @geo_location.country_code = "DE" }
      it { should == true }
    end
    describe "for an address outside europe" do
      before { @geo_location = GeoLocation.new; @geo_location.country_code = "US" }
      it { should == false }
    end
  end

  describe "#plz" do
    subject { @geo_location.plz }
    describe "for an address in Germany" do
      before do
        @geo_location = GeoLocation.new( address: @address_string )
        @geo_location.geocode
      end
      it { should == "10117" }
    end
    describe "for an address outside Germyn" do
      before do
        @geo_location = GeoLocation.new( address: "Some Address in UK" )
        @geo_location.country_code = "UK"
      end
      it { should == nil }
    end
  end

end
