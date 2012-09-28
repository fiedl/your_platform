# -*- coding: utf-8 -*-
require 'spec_helper'

describe ProfileField do

end


# Address Information
# ==========================================================================================

describe Address do

  before do
    @address_field = Address.create( label: "Address of the Brandenburg Gate",
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

end


# Studies Information
# ==========================================================================================

describe Study do

  subject { Study.create() }
  
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
