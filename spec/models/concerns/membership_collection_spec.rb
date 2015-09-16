require 'spec_helper'

describe MembershipCollection do
  
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
  
  describe "#where" do
    describe "Membership.where(user: ..., group: ...)" do
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
    
    describe "Membership.where(user: @user1)" do
      #
      #      page1 -------|
      #      group4 --- group2 --- group3 --- user1
      #
      before { @group4 = @group2.parent_groups.create name: 'group4' }
      subject { Membership.where(user: @user1) }
      it { should be_kind_of MembershipCollection }
      its(:to_a) { should be_kind_of Array }
      its(:first) { should be_kind_of Membership }
      its(:count) { should == 3 }
      it "should not perform too many queries" do
        # (User, Group, DagLink, Flag)  for the direct links
        # (Group, Flag, Flag) for each generation hop, in this case, 3 hops, without caching.
        count_queries(13) { subject.to_a }.should <= 13  # scales with number of hops
      end
      describe "when connected groups are already cached" do
        before { @user1.connected_ancestor_groups }
        it "should not perform too many queries" do
          # (User, Group, DagLink, Flag)  for the direct links
          # (Group, Flag)  for the indirect connected groups
          count_queries(6) { subject.to_a }.should <= 6  # does not scale with number of hops
        end
      end
    end
    
    describe "Membership.where(group: ...)" do
      #
      #      group2 --- group3 --- user1
      #
      describe "for groups that have direct members" do
        describe ".where(group: @group3)" do
          subject { Membership.where(group: @group3) }
          it { should be_kind_of MembershipCollection }
          its(:to_a) { should be_kind_of Array }
          its(:first) { should be_kind_of Membership }
          its(:count) { should == 1 }
          its('direct.count') { should == 1 }
          its('first.user') { should == @user1 }
          its('first.group') { should == @group3 }
        end
      end
      
      describe "for groups that have indirect members" do
        describe "Membership.where(group: @group2)" do
          subject { Membership.where(group: @group2) }
          it { should be_kind_of MembershipCollection }
          its(:to_a) { should be_kind_of Array }
          its(:first) { should be_kind_of Membership }
          its(:count) { should == 1 }
          its('direct.count') { should == 0 }
          its('first.user') { should == @user1 }
          its('first.group') { should == @group2 }
        end
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
  
  describe "#direct" do
    it "reduces the scope to direct memberships" do
      Membership.where(user: @user1).direct.count.should == 1
    end
    
    it "should be interchangable" do
      Membership.where(user: @user1).direct.to_a.should == Membership.direct.where(user: @user1).to_a
    end
  end
  
  describe "#uniq" do
    #
    #    @group1 --- @subgroup1 ------
    #       |                         |
    #       |------- @subgroup2 --- @user1
    #
    before do
      @group1 = create :group, name: 'group1'
      @subgroup1 = @group1.child_groups.create name: 'subgroup1'
      @subgroup2 = @group1.child_groups.create name: 'subgroup2'
      @user1 = create :user; @subgroup1 << @user1; @subgroup2 << @user1
    end
    subject { Membership.where(user: @user1).uniq }
    its(:count) { should == Membership.where(user: @user1).count - 1 }
  end
    
end