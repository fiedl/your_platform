# -*- coding: utf-8 -*-
require 'spec_helper'

# Profile Fields in General
# ==========================================================================================

describe ProfileField do
end


# Address Information
# ==========================================================================================

describe ProfileFieldTypes::Address do

  before do
    @address_field = ProfileFieldTypes::Address.create( label: "Address of the Brandenburg Gate",
                                                        value: "Pariser Platz 1\n 10117 Berlin" )

    create( :bv_group, name: "BV 00" ) # just to have another one in the database
    @bv = create( :bv_group, name: "BV 01", token: "BV 01" )

    BvMapping.create( bv_name: "BV 01", plz: "10117" )
  end

  describe "#bv" do
    subject { @address_field.bv }
    it "should return the correct Bv (Bezirksverband)" do
      subject.should == @bv
    end
  end

  describe "#display_html" do
    subject { @address_field.display_html }
    it "should include the BV" do
      subject.should include I18n.translate(:address_is_in_bv)
      subject.should include @address_field.bv.name
    end
  end

end


# Studies Information
# ==========================================================================================

describe ProfileFieldTypes::Study do

  subject { ProfileFieldTypes::Study.create() }
  
  its( 'children.count' ) { should == 5 }
  it { should respond_to :from }
  it { should respond_to :from= }
  it { should respond_to :to }
  it { should respond_to :to= }
  it { should respond_to :university }
  it { should respond_to :university= }
  it { should respond_to :subject }
  it { should respond_to :subject= }
  it { should respond_to :specialization }
  it { should respond_to :specialization= }
  
end
