require 'spec_helper'

describe GeoLocation do

  before do
    @address_string = "Pariser Platz 1\n 10117 Berlin"
    create( :bv_group, name: "BV 00" ) # just to have another one in the database
    @bv = create( :bv_group, name: "BV 01", token: "BV 01" )
    BvMapping.create( bv_name: "BV 01", plz: "10117" )

    @geo_location = GeoLocation.create( address: @address_string )
  end

  describe "#bv" do
    subject { @geo_location.bv }
    it "should return the correct Bv (Bezirksverband)" do
      subject.should == @bv
    end
  end

end
