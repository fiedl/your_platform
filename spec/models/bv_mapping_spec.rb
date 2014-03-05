require 'spec_helper'

describe BvMapping do
  
  describe ".find_or_create" do
    before { @args = {bv_name: 'BV 37', plz: '91054'} }
    subject { BvMapping.find_or_create(@args) }

    it { should_not be_nil }
    
    describe "for the mapping not existing" do
      it "should create the mapping" do
        BvMapping.find_by_plz(@args[:plz]).should == nil
        
        @mapping = subject
        BvMapping.find_by_plz(@args[:plz]).should == @mapping
      end
    end
    
    describe "for the mapping already existing" do
      before { @mapping = BvMapping.create(@args) }
      it "should return the existing mapping" do
        BvMapping.find_by_plz(@args[:plz]).should == @mapping
        subject.should == @mapping
        BvMapping.find_by_plz(@args[:plz]).should == @mapping
      end
    end
    
  end
  
end