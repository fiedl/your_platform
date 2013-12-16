require 'spec_helper'

describe GroupMixins::Memberships, :focus do
  
  #   @indirect_group
  #        |------------ @group
  #        |                |------ @user1
  #        |                |------ @user2
  #        |
  #        |------------ @group2
  #
  before do
    @group = create(:group)
    @user1 = create(:user); @group.assign_user(@user1)
    @user2 = create(:user); @group.assign_user(@user2)
    @membership1 = UserGroupMembership.find_by(user: @user1, group: @group)
    @membership2 = UserGroupMembership.find_by(user: @user2, group: @group)
    @indirect_group = @group.parent_groups.create
    @indirect_membership1 = UserGroupMembership.find_by(user: @user1, group: @indirect_group)
    @indirect_membership2 = UserGroupMembership.find_by(user: @user2, group: @indirect_group)
    @group2 = @indirect_group.child_groups.create
  end


  # User Group Memberships
  # ==========================================================================================
    
  describe "#memberships" do
    describe "for a group having direct members" do
      subject { @group.memberships }
      it { should include( @membership1, @membership2 ) }
      it { should_not include @indirect_membership1, @indirect_membership2 }
    end
    describe "for a group having indirect members" do
      subject { @indirect_group.memberships }
      it { should include @indirect_membership1, @indirect_membership2 }
      it { should_not include @membership1, @membership2 }
    end
  end
    
  describe "#direct_memberships" do
    describe "for a group having direct members" do
      subject { @group.direct_memberships }
      it { should include( @membership1, @membership2 ) }
      it { should_not include @indirect_membership1, @indirect_membership2 }
    end
    describe "for a group having indirect members" do
      subject { @indirect_group.direct_memberships }
      it { should_not include @indirect_membership1, @indirect_membership2 }
      it { should_not include @membership1, @membership2 }
    end    
  end
    
  describe "#indirect_memberships" do
    pending
  end

  describe "#assign_user" do
    pending
  end
    
  describe "#unassign_user           [at: time]" do
    pending
  end
    
  describe "#members" do
    pending
  end
    
  describe "#direct_members" do
    pending
  end
    
  describe "#indirect_members" do
    pending
  end
    
end
