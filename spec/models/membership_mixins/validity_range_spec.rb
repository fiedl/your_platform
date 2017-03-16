require 'spec_helper'

describe MembershipMixins::ValidityRange do
  
  before do
    @user = create(:user)
    @group = create(:group)
    @membership = Membership.create(user: @user, group: @group)
    @membership.reload
  end
  
  specify "preliminaries" do
    @membership.should_not be_changed
    @membership.id.should be_kind_of Integer
    @membership.should be_kind_of Membership
  end
  
  describe "#valid_from" do
    subject { @membership.valid_from }
    it { should be_kind_of Time }
    it "should be set to the created_at date by default" do
      subject.to_i.should > @membership.created_at.to_i-2
      subject.to_i.should < @membership.created_at.to_i+2
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
    end
    describe "setting an empty string" do
      subject { @membership.valid_from_localized_date = "" }
      it "should set valid_from to nil" do
        subject
        @membership.valid_from.should == nil
      end
    end
    describe "setting an invalid date" do
      subject { @membership.valid_from_localized_date = "FOO BAR" }
      it "should raise an error" do
        expect { subject }.to raise_error
      end
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
        @membership.valid_to.to_i.should > Time.zone.now.to_i-2
        @membership.valid_to.to_i.should < Time.zone.now.to_i+2
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
      @invalid_membership = Membership.create(user: @user, group: @group2)
      @invalid_membership.valid_from = 2.hours.ago
      @invalid_membership.invalidate(@time)
      @query = Membership.find_all_by_user(@user)
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
    
    describe "#now" do
      subject { @query.now }
      it "should return only memberships that are currently valid" do
        subject.should include @valid_membership
        subject.should_not include @invalid_membership
      end
    end
    describe "#in_the_past" do
      subject { @query.in_the_past }
      it "should return only memberships that are currently invalid" do
        subject.should_not include @valid_membership
        subject.should include @invalid_membership
      end
    end
    describe "#now_and_in_the_past" do
      subject { @query.now_and_in_the_past }
      it "should return both valid and invalid memberships" do
        subject.should include @valid_membership
        subject.should include @invalid_membership
      end
    end
  end
  
  describe "(validity range constraints)" do
    #
    #                     @time                   @now
    # ====================================================> time
    #                |------------------------------------> @membership1
    #                             |-----------------------> @membership2
    #                             |-----------|             @membership3
    # ----------------------------------------------------> @membership4
    #
    #
    before do
      @user1 = create :user
      @user2 = create :user
      @user3 = create :user
      @user4 = create :user
      @time = 1.year.ago
      @now = Time.zone.now
      @membership1 = @group.assign_user @user1, at: @time - 1.day
      @membership2 = @group.assign_user @user2, at: @time + 1.day
      @membership3 = @group.assign_user @user3, at: @time + 1.day; @membership3.invalidate at: 1.month.ago
      @membership4 = @group.assign_user @user4; @membership4.update_attribute(:valid_from, nil)
    end
    specify 'prelims' do
      @membership4.valid_from.should == nil
      @membership4.valid_to.should == nil
      @group.memberships.last.id.should == @membership4.id
      @group.memberships.last.valid_from.should == nil
    end
    describe ".now_and_in_the_past.started_after(time)" do
      subject { @group.memberships.now_and_in_the_past.started_after(@time) }
      it { should include @membership2 }
      it { should include @membership3 }
      it { should_not include @membership1 }
      it { should_not include @membership4 }
    end
    describe ".started_after(time)" do
      subject { @group.memberships.started_after(@time) }
      it { should include @membership2 }
      it { should_not include @membership3 }
      it { should_not include @membership1 }
      it { should_not include @membership4 }
    end
    describe "to_a.started_after(time)" do
      subject { @group.memberships.to_a.started_after(@time) }
      it { should include @membership2 }
      it { should_not include @membership3 }
      it { should_not include @membership1 }
      it { should_not include @membership4 }
    end
  end
end
