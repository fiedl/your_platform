require 'spec_helper'

describe UserGroupMembershipMixins::ValidityRangeForIndirectMemberships, :focus do

  # Memberships:
  #
  #       *-----------------(c)--------------------*
  #                          |
  #                |--------------------|
  #                |                    |
  #       *-------(a)--------*          | 
  #                          *---------(b)---------*
  #
  #       _________________________________________________________
  #       t1                 t2                    t3      time -->
  #
  # Structure:
  #
  #       indirect_group ........................... (c)
  #             |---------- direct_group ........... (a), (b)
  #                              |--------- user
  #       
  before do
    @user = create(:user)
    @indirect_group = create(:group)
    @direct_group_a = @indirect_group.child_groups.create
    @direct_group_b = @indirect_group.child_groups.create    
    @direct_group_a.assign_user @user
    @indirect_membership = UserGroupMembership.find_by_user_and_group(@user, @indirect_group)
    @direct_membership_a = UserGroupMembership.find_by_user_and_group(@user, @direct_group_a)
    @direct_membership_a.update_attribute(:valid_from, 2.hours.ago)
    @time = 1.hour.ago
    @direct_membership_a.move_to_group @direct_group_b, at: @time
    @direct_membership_b = UserGroupMembership.find_by_user_and_group(@user, @direct_group_b)
  end
  
  specify "preliminaries" do
    @direct_membership_a.valid_from.should < @direct_membership_b.valid_from
    #@direct_membership_a.valid_to.should < @direct_membership_b.valid_to
  end
  
  
  # Validity Range Attributes
  # ====================================================================================================
  
  describe "#valid_from" do
    subject { @indirect_membership.valid_from }
    it "should be the valid_from attribute of the earliest direct membership" do
      subject.to_i.should == @direct_membership_a.valid_from.to_i
    end
  end
  describe "#valid_from=" do
    before { @time = 30.minutes.ago }
    subject { @indirect_membership.valid_from = @time }
    it "should set the valid_from  attribute of the earliset direct membership" do
      subject
      @indirect_membership.save
      @direct_membership_a.reload.valid_from.should == @time
    end
  end
  
  describe "#valid_to" do
    subject { @indirect_membership.valid_to }
    pending
  end
  describe "#valid_to=" do
    pending
  end
  
  describe "#earliest_direct_membership" do
    subject { @indirect_membership.earliest_direct_membership }
    it { should == @direct_membership_a }
  end
  
  describe "#latest_direct_membership" do
    subject { @indirect_membership.latest_direct_membership }
    it { should == @direct_membership_b }
  end
  
  
  # Invalidation
  # ====================================================================================================
  
  describe "#make_invalid" do
    subject { @indirect_membership.make_invalid }
    it "should raise an error" do
      expect { subject }.to raise_error
    end
  end
  describe "#invalidate" do
    subject { @indirect_membership.invalidate }
    it "should raise an error" do
      expect { subject }.to raise_error
    end
  end


end
