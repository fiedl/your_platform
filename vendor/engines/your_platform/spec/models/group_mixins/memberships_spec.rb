require 'spec_helper'

describe GroupMixins::Memberships do
  
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
    describe "for a group having invalidated memberships" do
      before { @membership1.invalidate at: 10.minutes.ago }
      subject { @group.memberships }
      it { should include @membership2 }
      it { should == [ @membership2 ] }
      it "should not list the invalidated memberships, i.e. respect the default scope" do
        subject.should_not include @membership1
      end
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
    its(:new_record?) { should == true }    
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
        sleep 1.1  # to make sure the validity range time condition works
        @group.reload.members.should_not include @user
      end
    end
    describe "if the user is not a member" do
      it "should not raise an error" do
        @group.members.should_not include @user
        expect { @group.unassign_user @user }.to_not raise_error
      end
    end
  end


  # Members
  # ==========================================================================================

  describe "#members" do
    describe "for a group having direct members" do
      subject { @group.members }
      it { should include @user1, @user2 }
    end
    describe "for a group having indirect members" do
      subject { @indirect_group.members }
      it { should include @user1, @user2 }
    end
    describe "for a group having invalidated memberships" do
      before { @membership1.invalidate at: 10.minutes.ago }
      subject { @group.members }
      it { should include @user2 }
      it { should_not include @user1 }
    end
    describe "for a group having invalidated indirect memberships" do
      before { @membership1.invalidate at: 10.minutes.ago }
      subject { @indirect_group.members }
      it { should include @user2 }
      it { should_not include @user1 }
    end
    describe "members are unique" do
      before do
        @group_unique1 = create(:group)
        @group_unique2 = create(:group)
        @group_unique2.parent_groups << @group_unique1
        @group_unique3 = create(:group)
        @group_unique3.parent_groups << @group_unique2
        @user_unique = create(:user)
        @group_unique2 << @user_unique
        @group_unique2 << @user_unique
        @group_unique3 << @user_unique
      end
      subject { @group_unique1.members }
      it { should include @user_unique }
      it { should have(1).item }
    end
  end
  describe "#members << user" do
    subject { @group2.members << @user }
    it "should assign the given user as new direct member" do
      @user.should_not be_in @group2.members
      subject
      @user.should be_in @group2.members
      @user.should be_in @group2.direct_members
    end
  end
  describe "#members.destroy(user)" do
    describe "for the membership being direct" do
      subject { @group.members.destroy(@user1) }
      it "should remove the user from the members list" do
        @user1.should be_in @group.members
        subject
        @user1.should_not be_in @group.members
      end
      it "should remove the membership permanently" do
        subject
        UserGroupMembership.with_invalid.find_by_user_and_group(@user1, @group).should == nil
      end
    end
    describe "for the membership being indirect" do
      subject { @indirect_group.members.destroy(@user1) }
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
  end
    
  describe "#direct_members" do
    describe "for a group having direct members" do
      subject { @group.direct_members }
      it { should include @user1, @user2 }
    end
    describe "for a group having indirect members" do
      subject { @indirect_group.direct_members }
      it { should_not include @user1, @user2 }
    end
    describe "for a group having invalidated memberships" do
      before { @membership1.invalidate at: 10.minutes.ago }
      subject { @group.direct_members }
      it { should include @user2 }
      it { should_not include @user1 }
    end
    describe "group with only indirect members" do
      before do
        @group_unique1 = create(:group)
        @group_unique2 = create(:group)
        @group_unique2.parent_groups << @group_unique1
        @user_unique = create(:user)
        @group_unique2 << @user_unique
      end
      subject { @group_unique1.direct_members }
      it { should have(0).items }
    end
    describe "group with direct and indirect member" do
      before do
        @group_unique1 = create(:group)
        @group_unique2 = create(:group)
        @group_unique2.parent_groups << @group_unique1
        @group_unique3 = create(:group)
        @group_unique3.parent_groups << @group_unique2
        @user_unique = create(:user)
        @group_unique2 << @user_unique
        @group_unique2 << @user_unique
        @group_unique3 << @user_unique
      end
      subject { @group_unique2.direct_members }
      it { should include @user_unique }
      it { should have(1).item }
    end
  end
    
  describe "#indirect_members" do
    describe "for a group having direct members" do
      subject { @group.indirect_members }
      it { should_not include @user1, @user2 }
    end
    describe "for a group having indirect members" do
      subject { @indirect_group.indirect_members }
      it { should include @user1, @user2 }
    end
    describe "for a group having invalidated memberships" do
      before { @membership1.invalidate at: 10.minutes.ago }
      subject { @indirect_group.indirect_members }
      it { should include @user2 }
      it { should_not include @user1 }
    end
    describe "group with indirect members only" do
      before do
        @group_unique1 = create(:group)
        @group_unique2 = create(:group)
        @group_unique2.parent_groups << @group_unique1
        @group_unique3 = create(:group)
        @group_unique3.parent_groups << @group_unique2
        @group_unique4 = create(:group)
        @group_unique4.parent_groups << @group_unique1
        @user_unique1 = create(:user)
        @user_unique2 = create(:user)
        @group_unique2 << @user_unique1
        @group_unique2 << @user_unique1
        @group_unique3 << @user_unique1
        @group_unique3 << @user_unique2
        @group_unique4 << @user_unique2
      end
      subject { @group_unique1.indirect_members }
      it { should have(2).items }
      it { should include @user_unique1 }
      it { should include @user_unique2 }
    end
  end
  
  describe "#direct_member_titles_string" do
    subject { @group.direct_members_titles_string }
    it { should == "#{@user1.title}, #{@user2.title}" }
  end
  describe "#direct_member_titles_string=" do
    before { @group.direct_members_titles_string = "#{@user1.title}"; sleep 1.1 }
    it "should set the memberships according to the titles" do
      @group.reload.memberships.should include( @membership1 )
      @group.reload.memberships.should_not include( @membership2 )
    end
  end
  
    
end
