require 'spec_helper'

describe UserMixins::Memberships do

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
    @membership1 = Membership.find_by(user: @user1, group: @group)
    @membership2 = Membership.find_by(user: @user2, group: @group)
    @indirect_group = @group.parent_groups.create
    @indirect_membership1 = Membership.find_by(user: @user1, group: @indirect_group)
    @indirect_membership2 = Membership.find_by(user: @user2, group: @indirect_group)
    @group2 = @indirect_group.child_groups.create
  end


  # User Group Memberships
  # ==========================================================================================

  describe "#memberships" do
    subject { @user1.memberships }
    it { should include @membership1 }
    it { should include @indirect_membership1 }
    it "should not include invalidated memberships" do
      @membership1.invalidate at: 10.minutes.ago
      subject { should_not include @membership1 }
    end
    it "should not include invalidated indirect memberships" do
      @membership1.invalidate at: 10.minutes.ago
      subject { should_not include @indirect_membership1 }
    end
  end

  describe "#direct_memberships" do
    subject { @user1.direct_memberships }
    it { should include @membership1 }
    it { should_not include @indirect_membership1 }
  end

  describe "#indirect_memberships" do
    subject { @user1.indirect_memberships }
    it { should include @indirect_membership1 }
    it { should_not include @membership1 }
  end


  describe "#membership_in( group )" do
    describe "for the user being a direct member" do
      subject { @user.membership_in @group }
      it { should == @membership1 }
    end
    describe "for the user being an indirect member" do
      subject { @user.membership_in @indirect_group }
      it { should == @indirect_membership1 }
    end
  end

  describe "#member_of?( group )" do
    describe "for the user being direct member" do
      subject { @user.member_of? @group}
      it { should == true }
    end
    describe "for the user being indirect member" do
      subject { @user.member_of? @indirect_group }
      it { should == true }
    end
    describe "for the user not being a member" do
      subject { @user.member_of? @group2 }
      it { should == false }
    end
  end


  # Groups the user is member of
  # ==========================================================================================

  describe "#groups" do
    subject { @user1.groups }
    it { should include @group }
    it { should include @indirect_group }
    it "should not include groups of invalidated memberships" do
      @membership1.invalidate at: 10.minutes.ago
      run_background_jobs  # to update the indirect validity ranges
      subject.should_not include @group
      subject.should_not include @indirect_group
    end
  end
  describe "#groups << group" do
    subject { @user.groups << @group2 }
    it "should assign the user to the given group" do
      @user.should_not be_in @group2.members
      subject
      @user.should be_in @group2.members
      @user.should be_in @group2.direct_members
    end
  end
  describe "#groups.destroy(group)" do
    describe "for the membership being direct" do
      subject { @user.groups.destroy(@group) }
      it "should remove the user from the members list" do
        @user1.should be_in @group.members
        subject
        @user1.should_not be_in @group.members
      end
      it "should remove the membership permanently" do
        subject
        Membership.with_invalid.find_by_user_and_group(@user1, @group).should == nil
      end
    end
    describe "for the membership being indirect" do
      subject { @user.groups.destroy(@indirect_group) }
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
  end

  describe "#direct_groups" do
    subject { @user.direct_groups }
    it { should include @group }
    it { should_not include @indirect_group }
  end

  describe "#indirect_groups" do
    subject { @user.indirect_groups }
    it { should include @indirect_group }
    it { should_not include @group }
  end

end
