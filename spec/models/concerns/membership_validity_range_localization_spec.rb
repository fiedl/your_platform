require 'spec_helper'

describe MembershipValidityRangeLocalization do
  
  #
  #    @group1 --- @user1
  #
  before do
    @group1 = create :group, name: 'group1'
    @user1 = create :user
    @membership = Membership.create user: @user1, group: @group1
  end
  
  describe "#valid_from_localized_date" do
    subject { @membership.valid_from_localized_date }
    describe "if no valid_from given" do
      before { @membership.valid_from = nil }
      it { should == "" }
    end
    describe "if a datetime given" do
      before do
        @time = "1.1.2013 12:30 UTC".to_datetime
        @membership.valid_from = @time 
      end
      it { should == "01.01.2013" }
    end
  end
  
  describe "#valid_from_localized_date=" do
    describe "setting a date string" do
      subject { @membership.valid_from_localized_date = "1.1.2013" }
      it "should set the correct date" do
        subject
        @membership.valid_from.to_date.should == "1.1.2013".to_date
      end
      it "should set the date persistently when saved" do
        subject
        @membership.save
        @membership.reload.valid_from.to_date.should == "1.1.2013".to_date
      end
    end
    describe "setting an empty string" do
      subject { @membership.valid_from_localized_date = "" }
      it "should set valid_from to nil" do
        subject
        @membership.valid_from.should == nil
      end
      it "should set the date persistently when saved" do
        subject
        @membership.save
        @membership.reload.valid_from.should == nil
      end
    end
    describe "setting an invalid date" do
      subject { @membership.valid_from_localized_date = "FOO BAR" }
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
  end
  
  
  describe "#valid_to_localized_date" do
    subject { @membership.valid_to_localized_date }
    describe "if no valid_to given" do
      before { @membership.valid_to = nil }
      it { should == "" }
    end
    describe "if a datetime given" do
      before do
        @time = "1.1.2013 12:30 UTC".to_datetime
        @membership.valid_to = @time 
      end
      it { should == "01.01.2013" }
    end
  end
  
  describe "#valid_to_localized_date=" do
    describe "setting a date string" do
      subject { @membership.valid_to_localized_date = "1.1.2013" }
      it "should set the correct date" do
        subject
        @membership.valid_to.to_date.should == "1.1.2013".to_date
      end
      it "should set the date persistently when saved" do
        subject
        @membership.save
        @membership.reload.valid_to.to_date.should == "1.1.2013".to_date
      end
    end
    describe "setting an empty string" do
      subject { @membership.valid_to_localized_date = "" }
      it "should set valid_to to nil" do
        subject
        @membership.valid_to.should == nil
      end
      it "should set the date persistently when saved" do
        subject
        @membership.save
        @membership.reload.valid_to.should == nil
      end
    end
    describe "setting an invalid date" do
      subject { @membership.valid_to_localized_date = "FOO BAR" }
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
  end
  
  
end