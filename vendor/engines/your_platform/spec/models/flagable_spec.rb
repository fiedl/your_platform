require 'spec_helper'

# Pages are flagable. Therefore, the Page model is used as an example here.

describe "Flagable" do

  before { @flagable = Page.create( title: "Flagable Page" ) }
  subject { @flagable }
  
  describe "#add_flags( :flag1, :flag2, ... )" do
    it "should add the given flags" do
      subject.add_flags( :flag1, :flag2, :flag3 )
      subject.has_flag?( :flag1 ).should be_true
    end
    it "should ignore flags that are already set" do
      subject.add_flags( :flag1, :flag2 )
      subject.add_flags( :flag1 )
      subject.flags_to_syms.should == [ :flag1, :flag2 ]
    end
  end

  describe "#add_flag :flag1" do
    it "should add the given flag" do
      subject.add_flag( :flag1 )
      subject.has_flag?( :flag1 ).should be_true
    end
  end

  describe "#remove_flags" do
    it "should remove the given flags" do
      subject.add_flags :flag1, :flag2
      subject.remove_flags :flag1
      @flagable = Page.last # to avoid caching
      @flagable.flags_to_syms.should == [ :flag2 ]
    end
  end

  describe "#flags_to_syms" do
    it "should return an array of syms that express the flags" do
      subject.add_flags( :flag1, :flag2 )
      subject.flags_to_syms.should == [ :flag1, :flag2 ]
    end
  end

  describe "#has_flag?" do
    it "should return true if the Flagable has the flag" do
      subject.add_flags( :flag1 )
      subject.has_flag?( :flag1 ).should be_true
    end
    it "should return false if the Flagbale doesn't have the flag" do
      subject.has_flag?( :flag4 ).should be_false
    end
  end

end
