require 'spec_helper'

describe GroupMemberAssignment do
  
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
        time_travel 2.seconds
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

  describe "#direct_member_titles_string" do
    subject { @group.direct_members_titles_string }
    it { should == "#{@user1.title}, #{@user2.title}" }
  end
  describe "#direct_member_titles_string=" do
    before { @group.direct_members_titles_string = "#{@user1.title}"; time_travel 2.seconds }
    it "should set the memberships according to the titles" do
      @group.reload.memberships.should include( @membership1 )
      @group.reload.memberships.should_not include( @membership2 )
    end
  end
  
end
