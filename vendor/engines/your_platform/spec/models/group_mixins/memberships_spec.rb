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
    @user = @user1
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
    describe "for a group having direct members" do
      subject { @group.indirect_memberships }
      it { should_not include( @membership1, @membership2 ) }
      it { should_not include @indirect_membership1, @indirect_membership2 }
    end
    describe "for a group having indirect members" do
      subject { @indirect_group.indirect_memberships }
      it { should include @indirect_membership1, @indirect_membership2 }
      it { should_not include @membership1, @membership2 }
    end    
  end
  
  describe "#build_membership" do
    subject { @group.build_membership }
    it { should be_kind_of UserGroupMembership }
    its(:ancestor_type) { should == 'Group' }
    its(:ancestor_id) { should == @group.id }
    its(:descendant_type) { should == 'User' }
    its(:descendant_id) { should == nil }
  end
  
  describe "#membership_of( user )" do
    subject { @group.membership_of(@user1) }
    it { should be_kind_of UserGroupMembership }
    it { should == @membership1 }
  end
  
  
  # User Assignment
  # ==========================================================================================
  
  describe "#assign_user" do
    before { @membership1.destroy }
    it "should assign the user to the group" do
      @group.members.should_not include @user
      @group.assign_user @user
      @group.reload
      @group.members.should include @user
    end
    describe "for users that are already members" do
      before { @group.direct_members << @user }
      it "should just keep them as members" do
        @group.members.should include @user
        @group.assign_user @user
        @group.reload
        @group.members.should include @user
      end
    end
  end

  describe "#unassign_user" do
    before { @membership1.destroy }
    describe "if the user is a member" do
      before { @group.direct_members << @user }
      it "should remove the membership" do
        @group.members.should include @user
        @group.unassign_user @user
        @group.reload
        @group.members.reload.should_not include @user
      end
    end
    describe "if the user is not a member" do
      it "should not raise an error" do
        @group.members.should_not include @user
        expect { @group.unassign_user @user }.to_not raise_error
      end
    end
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
