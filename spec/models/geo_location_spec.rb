require 'spec_helper'

describe GeoLocation do

  before do
    @address_string = "Pariser Platz 1\n 10117 Berlin"
    @address2_string = "44 Rue de Stalingrad, Grenoble, Frankreich"
    create( :bv_group, name: "BV 00" ) # just to have another one in the database
    @bv = create( :bv_group, name: "BV 01", token: "BV 01" )
    @bv_europe = create( :bv_group, name: "BV 45", token: "BV 45" )
    BvMapping.create( bv_name: "BV 01", plz: "10117" )

    @geo_location = GeoLocation.create( address: @address_string )
    @geo_location2 = GeoLocation.create( address: @address2_string )
    @geo_location2.geocode_and_save
  end

  describe "#bv" do
    subject { @geo_location.bv }
    it "should return the correct Bv (Bezirksverband)" do
      should == @bv
    end
  end

  describe "#bv" do
      before do
      end
    subject { @geo_location2.bv }
    it "should work as well out of europe" do
      should == @bv_europe
    end
  end

end
