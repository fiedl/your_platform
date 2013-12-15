require 'spec_helper'

describe UserGroupMembershipMixins::ValidityRange do
  
  before do
    @user = create(:user)
    @group = create(:group)
    @membership = UserGroupMembership.create(user: @user, group: @group)
  end
  
  specify "preliminaries" do
    @membership.should_not be_changed
    @membership.id.should be_kind_of Integer
    @membership.should be_kind_of UserGroupMembership
  end
  
  describe "#valid_from" do
    subject { @membership.valid_from }
    it { should be_kind_of Time }
    it "should be set to the created_at date by default" do
      subject.to_i.should == @membership.created_at.to_i
    end
  end
  describe "#valid_to" do
    subject { @membership.valid_to }
    describe "being unset" do
      it { should == nil }
    end
    describe "being set" do
      before { @membership.valid_to = 1.hour.ago }
      it { should be_kind_of Time }
    end
  end
  
  describe "#make_invalid" do
    describe "with time argument" do
      before { @time = 1.hour.ago }
      subject { @membership.make_invalid(@time) }
      it "should set the valid_to argument to the given time" do
        @membership.valid_to.should == nil
        subject
        @membership.valid_to.should == @time
      end
      it "should mark the membership as invalid" do
        @membership.currently_valid?.should == true
        subject
        @membership.currently_valid?.should == false
      end
      it "should return the membership" do
        subject.should == @membership
      end
      describe "with 'at: time' argument" do
        subject { @membership.make_invalid at: @time }
        it "should set the valid_to argument to the given time" do
          @membership.valid_to.should == nil
          subject
          @membership.valid_to.should == @time
        end
      end
    end
    describe "without argument" do
      subject { @membership.make_invalid }
      it "should set the end of the validity to the current time" do
        @membership.valid_to.should == nil
        subject
        @membership.valid_to.to_i.should == Time.zone.now.to_i
      end
    end
  end
  
  describe "#invalidate" do
    describe "with time argument" do
      before { @time = 1.hour.ago }
      subject { @membership.invalidate(@time) }
      it "should set the valid_to argument to the given time" do
        @membership.valid_to.should == nil
        subject
        @membership.valid_to.should == @time
      end
      it "should mark the membership as invalid" do
        @membership.currently_valid?.should == true
        subject
        @membership.currently_valid?.should == false
      end
      it "should return the membership" do
        subject.should == @membership
      end
      describe "with 'at: time' argument" do
        subject { @membership.invalidate at: @time }
        it "should set the valid_to argument to the given time" do
          @membership.valid_to.should == nil
          subject
          @membership.valid_to.should == @time
        end
      end
    end
    describe "without argument" do
      subject { @membership.invalidate }
      it "should set the end of the validity to the current time" do
        @membership.valid_to.should == nil
        subject
        @membership.valid_to.to_i.should == Time.zone.now.to_i
      end
    end
  end
  
  describe "#currently_valid?" do
    subject { @membership.currently_valid? }
    it "should check whether the membership is valid in terms of the validity range at present time" do
      @membership.currently_valid?.should == true
      @membership.invalidate
      @membership.currently_valid?.should == false
    end
  end
  describe "#valid_at?(time)" do
    before do
      @time = 1.hour.ago
      @membership.update_attribute(:valid_from, @time)
    end
    subject { @membership.valid_at? @time }
    it "should check whether the membership is valid in terms of the validity range at the given time" do
      @membership.valid_at?(@time).should == true
      @membership.invalidate at: (@time - 1.hour)
      @membership.valid_at?(@time).should == false
    end
  end
  
  describe "(temporal scopes)" do
    before do
      @valid_membership = @membership
      @valid_membership.update_attribute(:valid_from, 2.hours.ago)
      @group2 = create(:group)
      @time = 1.hour.ago
      @invalid_membership = UserGroupMembership.create(user: @user, group: @group2)
      @invalid_membership.valid_from = 2.hours.ago
      @invalid_membership.invalidate(@time)
      @query = UserGroupMembership.find_all_by_user(@user)
    end
    
    describe "#at_time" do
      subject { @query.at_time(@time + 1.minute) }
      it "should limit the search to match the validity range" do
        subject.should include @valid_membership
        subject.should_not include @invalid_membership
      end
    end
    
    describe "#only_valid" do
      subject { @query.only_valid }
      it "should return only memberships that are currently valid" do
        subject.should include @valid_membership
        subject.should_not include @invalid_membership
      end
    end
    
    describe "#only_invalid" do
      subject { @query.only_invalid }
      it "should return only memberships that are currently invalid" do
        subject.should_not include @valid_membership
        subject.should include @invalid_membership
      end
    end
    
    describe "#with_invalid" do
      subject { @query.with_invalid } 
      it "should return both valid and invalid memberships" do
        subject.should include @valid_membership
        subject.should include @invalid_membership
      end
    end
    
    describe "(by default)" do
      subject { @query }
      it "should return only currently valid memberships" do
        subject.should include @valid_membership
        subject.should_not include @invalid_membership
      end
    end
  end
  
end
