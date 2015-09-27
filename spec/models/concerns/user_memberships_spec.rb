require 'spec_helper'

describe UserMemberships do
  
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
    @membership1 = Membership.where(user: @user1, group: @group).first
    @membership2 = Membership.where(user: @user2, group: @group).first
    @indirect_group = @group.parent_groups.create
    @indirect_membership1 = Membership.where(user: @user1, group: @indirect_group).first
    @indirect_membership2 = Membership.where(user: @user2, group: @indirect_group).first
    @group2 = @indirect_group.child_groups.create
  end
  
  describe "(Memberships)" do
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
    
    describe "#memberships_in(group)" do
      describe "for the user being a direct member" do
        subject { @user.memberships_in @group }
        it { should be_kind_of MembershipCollection }
        it { should include @membership1 }
      end
      describe "for the user being an indirect member" do
        subject { @user.memberships_in @indirect_group }
        it { should be_kind_of MembershipCollection }
        it { should include @indirect_membership1 }
      end
    end
    
    describe "#membership_in(group)" do
      describe "for the user being a direct member" do
        subject { @user.membership_in @group }
        it { should == @membership1 }
      end
      describe "for the user being an indirect member" do
        subject { @user.membership_in @indirect_group }
        it { should == @indirect_membership1 }
      end
    end
    
    describe "#member_of?(group) [defined in UserRoles]" do
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
  end
  
  describe "(Groups)" do
    #
    #   @indirect_group
    #        |------------ @group
    #        |                |------ @user1  # @membership1
    #        |                |------ @user2
    #        |
    #        |------------ @group2
    #                         |------ @user1
    #
    before do
      Membership.create user: @user1, group: @group2
    end
    
    describe "#groups" do
      subject { @user1.groups }
      it { should include @group }
      it { should include @indirect_group }
      describe "when a direct membership has been invalidated" do
        before { @membership1.invalidate at: 10.minutes.ago }
        it { should_not include @group }
        it { should include @group2 }
        it { should include @indirect_group }
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
      its(:count) { should == 1 }
    end
  end
end