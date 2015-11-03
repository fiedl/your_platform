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
      
      describe "when there are direct and indirect memberships" do
        #   @indirect_group
        #        |------------ @group
        #        |                |------ @user1
        #        |                |------ @user2
        #        |
        #        |------------ @group2
        #
        before do
          @group = create(:group, name: 'group')
          @user1 = create(:user); @group.assign_user(@user1)
          @user2 = create(:user); @group.assign_user(@user2)
          @user = @user1
          @membership1 = Membership.where(user: @user1, group: @group).first
          @membership2 = Membership.where(user: @user2, group: @group).first
          @indirect_group = @group.parent_groups.create name: 'indirect_group'
          @indirect_membership1 = Membership.where(user: @user1, group: @indirect_group).first
          @indirect_membership2 = Membership.where(user: @user2, group: @indirect_group).first
          @group2 = @indirect_group.child_groups.create
        end
        describe "when the selector group is a direct group" do
          subject { Membership.where(group: @group, user: @user) }
          its(:count) { should == 1 }
          its(:first) { should == @membership1 }
          its(:first) { should be_kind_of Membership }
          its('first.group') { should == @group }
          its('first.user') { should == @user }
        end
        describe "when the selector group is an indirect group" do
          subject { Membership.where(group: @indirect_group, user: @user) }
          its(:count) { should == 1 }
          its(:first) { should == @indirect_membership1 }
          its(:first) { should be_kind_of Membership }
          its('first.group') { should == @indirect_group }
          its('first.user') { should == @user }
        end
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
  
  describe "#first_per_group" do
    # If a user has two memberships in a group, differing in the validity range,
    # this filter selects the first, i.e. earliest, membership for each group.
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
      @time1 = 1.year.ago; @time2 = 6.months.ago; @time3 = 2.months.ago; @time4 = nil
      Membership.where(user: @user1, group: @subgroup1).first.update_attributes valid_from: @time1, valid_to: @time2
      Membership.where(user: @user1, group: @subgroup2).first.update_attributes valid_from: @time3, valid_to: @time4
    end
    describe "with past memberships" do
      subject { Membership.where(group: @group1).first_per_group }
      it { should be_kind_of MembershipCollection }
      its(:count) { should == 1 }
      its('first.valid_from.to_i') { should == @time1.to_i }
    end
    describe "only current memberships" do
      subject { Membership.where(group: @group1).now.first_per_group }
      it { should be_kind_of MembershipCollection }
      its(:count) { should == 1 }
      its('first.valid_from.to_i') { should == @time3.to_i }
    end
  end
  
  describe "#groups" do
    #      group1 --- page1 --- group2 --- group3 --- user1
    #        |
    #        |------- user2
    before { @membership_collection = @user1.memberships }
    subject { @membership_collection.groups }
    it { should be_kind_of GroupCollection }
    it { should include @group2, @group3 }
    describe "for #direct" do
      before { @membership_collection = @membership_collection.direct }
      it { should_not include @group2 }
    end
    describe "for #indirect" do
      before { @membership_collection = @membership_collection.indirect }
      it { should_not include @group1 }
    end
  end
  
  describe "#destroy_all" do
    # Example: 
    #
    #      group1 --- page1 --- group2 --- group3 --- user1
    #        |
    #        |------- user2
    #        |-------group4 --- user1 (past membership)
    #
    before do
      @group4 = @group1.child_groups.create name: 'group4'
      @group4 << @user1
      Membership.where(user: @user1, group: @group4).first.invalidate at: 10.days.ago

      @memberships = Membership.where(user: @user1)
    end
    describe "for #now" do
      subject { @memberships.now.destroy_all; Membership.where(user: @user1).groups }
      it { should include @group1, @group4 }
      it { should_not include @group3, @group2 }
    end
    
    describe "for #past" do
      subject { @memberships.past.destroy_all; Membership.where(user: @user1).groups }
      it { should_not include @group1, @group4 }
      it { should include @group3, @group2 }
    end

    describe "for #with_past" do
      subject { @memberships.with_past.destroy_all; Membership.where(user: @user1).groups }
      it { should_not include @group1, @group4 }
      it { should_not include @group3, @group2 }
    end
  end
  
  describe "#join_validity_ranges_of_indirect_memberships" do
    # Join the validity ranges of indirect memberships.
    #
    #     @group1
    #        |------- @subgroup1 -----|
    #        |------- @subgroup2 --- @user1
    #
    # First, user1 joins subgroup1, then moves to subgroup2.
    #
    #    |-----------|                   first indirect membership in @group1
    #                |---------          second indirect membership in @group2
    #    |---------------------          joined indirect membership
    #
    before do
      @group1 = create :group, name: 'group1'
      @subgroup1 = @group1.child_groups.create name: 'subgroup1'
      @subgroup2 = @group1.child_groups.create name: 'subgroup2'
      @user1 = create :user; @subgroup1 << @user1; @subgroup2 << @user1
      @time1 = 1.year.ago; @time2 = 6.months.ago; @time3 = 2.months.ago; @time4 = nil
      Membership.where(user: @user1, group: @subgroup1).first.update_attributes valid_from: @time1, valid_to: @time2
      Membership.where(user: @user1, group: @subgroup2).first.update_attributes valid_from: @time3, valid_to: @time4
    end
    describe "for a group" do
      subject { Membership.where(group: @group1).join_validity_ranges_of_indirect_memberships }
      it { should be_kind_of MembershipCollection }
      it "should join the indirect memberships, i.e. count only one membership, not two" do
        subject.count.should == 1
      end
      its('first.valid_from.to_i') { should == @time1.to_i }
      describe "for a right-open interval" do
        before do
          @time4 = nil
          Membership.where(user: @user1, group: @subgroup2).first.update_attributes valid_from: @time3, valid_to: @time4
        end
        its('first.valid_from.to_i') { should == @time1.to_i }
        its('first.valid_to.to_i') { should == @time4.to_i }
      end
      describe "for a left-open interval" do
        before do
          @time1 = nil
          @time4 = 1.day.ago
          Membership.where(user: @user1, group: @subgroup1).first.update_attributes valid_from: @time1, valid_to: @time2
          Membership.where(user: @user1, group: @subgroup2).first.update_attributes valid_from: @time3, valid_to: @time4
        end
        its('first.valid_from.to_i') { should == @time1.to_i }
        its('first.valid_to.to_i') { should == @time4.to_i }
      end
      describe "for a closed interval" do
        before do
          @time4 = 1.day.ago
          Membership.where(user: @user1, group: @subgroup2).first.update_attributes valid_from: @time3, valid_to: @time4
        end
        its('first.valid_from.to_i') { should == @time1.to_i }
        its('first.valid_to.to_i') { should == @time4.to_i }
      end
    end
    describe "for a user" do
      subject { Membership.where(user: @user1).join_validity_ranges_of_indirect_memberships }
      it { should be_kind_of MembershipCollection }
      it "should join the indirect memberships, i.e. count only one membership, not two" do
        subject.count.should == 3
        subject.indirect.count.should == 1
      end
      describe "for a right-open interval" do
        before do
          @time4 = nil
          Membership.where(user: @user1, group: @subgroup2).first.update_attributes valid_from: @time3, valid_to: @time4
        end
        its('indirect.first.valid_from.to_i') { should == @time1.to_i }
        its('indirect.first.valid_to.to_i') { should == @time4.to_i }
      end
      describe "for a left-open interval" do
        before do
          @time1 = nil
          @time4 = 1.day.ago
          Membership.where(user: @user1, group: @subgroup1).first.update_attributes valid_from: @time1, valid_to: @time2
          Membership.where(user: @user1, group: @subgroup2).first.update_attributes valid_from: @time3, valid_to: @time4
        end
        its('indirect.first.valid_from.to_i') { should == @time1.to_i }
        its('indirect.first.valid_to.to_i') { should == @time4.to_i }
      end
      describe "for a closed interval" do
        before do
          @time4 = 1.day.ago
          Membership.where(user: @user1, group: @subgroup2).first.update_attributes valid_from: @time3, valid_to: @time4
        end
        its('indirect.first.valid_from.to_i') { should == @time1.to_i }
        its('indirect.first.valid_to.to_i') { should == @time4.to_i }
      end
    end
    describe "for user and group" do
      subject { Membership.where(user: @user1, group: @group1).join_validity_ranges_of_indirect_memberships }
      it { should be_kind_of MembershipCollection }
      it "should join the indirect memberships, i.e. count only one membership, not two" do
        subject.count.should == 1
        subject.indirect.count.should == 1
      end
      describe "for a right-open interval" do
        before do
          @time4 = nil
          Membership.where(user: @user1, group: @subgroup2).first.update_attributes valid_from: @time3, valid_to: @time4
        end
        its('first.valid_from.to_i') { should == @time1.to_i }
        its('first.valid_to.to_i') { should == @time4.to_i }
      end
      describe "for a left-open interval" do
        before do
          @time1 = nil
          @time4 = 1.day.ago
          Membership.where(user: @user1, group: @subgroup1).first.update_attributes valid_from: @time1, valid_to: @time2
          Membership.where(user: @user1, group: @subgroup2).first.update_attributes valid_from: @time3, valid_to: @time4
        end
        its('first.valid_from.to_i') { should == @time1.to_i }
        its('first.valid_to.to_i') { should == @time4.to_i }
      end
      describe "for a closed interval" do
        before do
          @time4 = 1.day.ago
          Membership.where(user: @user1, group: @subgroup2).first.update_attributes valid_from: @time3, valid_to: @time4
        end
        its('first.valid_from.to_i') { should == @time1.to_i }
        its('first.valid_to.to_i') { should == @time4.to_i }
      end
    end
    
  end
    
end