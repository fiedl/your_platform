require 'spec_helper'

describe Membership do
  
  # Example: 
  #
  #      group1 --- page1 --- group2 --- group3 --- user1
  #        |
  #        |------- user2
  #
  before do
    @group1 = create :group, name: 'group1'
    @page1 = @group1.child_pages.create title: 'page1'
    @group2 = @page1.child_groups.create name: 'group2'
    @group3 = @group2.child_groups.create name: 'group3'
    @user1 = create :user; @group3 << @user1
    @user2 = create :user; @group1 << @user2
  end
  
  describe ".where" do
    describe ".where(user: ..., group: ...)" do
      describe "for a direct membership" do
        subject { Membership.where(user: @user1, group: @group3) }
        its(:count) { should == 1 }
        its('first.user') { should == @user1 }
        its('first.group') { should == @group3 }
        its('first.direct?') { should == true }
      end
      describe "for an indirect membership" do
        subject { Membership.where(user: @user1, group: @group2) }
        its(:count) { should == 1 }
        its('first.user') { should == @user1 }
        its('first.group') { should == @group2 }
        its('first.direct?') { should == false }
      end
    end
    
    describe ".where(user: @user1)" do
      subject { Membership.where(user: @user1) }
      it { should be_kind_of MembershipCollection }
      its(:to_a) { should be_kind_of Array }
      its(:first) { should be_kind_of Membership }
      its(:count) { should == 2 }
    end
    
    describe "for groups that have direct members" do
      describe ".where(group: @group3)" do
        subject { Membership.where(group: @group3) }
        it { should be_kind_of MembershipCollection }
        its(:to_a) { should be_kind_of Array }
        its(:first) { should be_kind_of Membership }
        its(:count) { should == 1 }
        its('direct.count') { should == 1 }
      end
    end
    
    describe "for groups that have indirect members" do
      describe ".where(group: @group2)" do
        subject { Membership.where(group: @group2) }
        it { should be_kind_of MembershipCollection }
        its(:to_a) { should be_kind_of Array }
        its(:first) { should be_kind_of Membership }
        its(:count) { should == 1 }
        its('direct.count') { should == 0 }
      end
    end
    
    describe "for user and group" do
      describe "when the link is direct" do
        subject { Membership.where(group: @group3, user: @user1) }
        it { should be_kind_of MembershipCollection }
        its(:to_a) { should be_kind_of Array }
        its(:first) { should be_kind_of Membership }
        its(:count) { should == 1 }
        its('direct.count') { should == 1 }
      end
      
      describe "when the link is not direct" do
        subject { Membership.where(group: @group2, user: @user1) }
        it { should be_kind_of MembershipCollection }
        its(:to_a) { should be_kind_of Array }
        its(:first) { should be_kind_of Membership }
        its(:count) { should == 1 }
        its('direct.count') { should == 0 }
      end
    end
  end
  
  describe ".direct" do
    it "reduces the scope to direct memberships" do
      Membership.where(user: @user1).direct.count.should == 1
    end
    
    it "should be interchangable" do
      Membership.where(user: @user1).direct.to_a.should == Membership.direct.where(user: @user1).to_a
    end
  end
  
  describe "#save!" do
    subject { @membership.save! }
    
    describe "for direct memberships" do
      before { @membership = Membership.where(user: @user2, group: @group1).first }
      it "should save a changed valid_from and valid_to attributes" do
        @membership.valid_from = @time1 = 2.months.ago
        @membership.valid_to = @time2 = 1.month.ago
        subject
        @membership.reload.valid_from.to_i.should == @time1.to_i
        @membership.reload.valid_to.to_i.should == @time2.to_i
        @membership.dag_link.reload.valid_from.to_i.should == @time1.to_i
        @membership.dag_link.reload.valid_to.to_i.should == @time2.to_i
      end
    end
    
    describe "for indirect memberships" do
      before { @membership = Membership.where(user: @user1, group: @group2).first }
      specify "requirements" do
        @membership.user.should == @user1
        @membership.group.should == @group2
      end
      it "should raise an error, since indirect memberships are non-persistent objects" do
        expect { subject }.to raise_error
      end
    end
  end
  
end