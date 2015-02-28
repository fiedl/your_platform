require 'spec_helper'

describe Flag do

  before { @flag = Flag.create( :key => :flag1 ) }
  subject { @flag }

  describe "#to_sym" do
    its( :to_sym ) { should == :flag1 }
  end

  describe "#to_s" do
    its( :to_s ) { should == "flag1" }
  end

  describe "#inspect" do
    its( :inspect ) { should == subject.to_sym }
  end

end
