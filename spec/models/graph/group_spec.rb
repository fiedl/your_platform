require 'spec_helper'

describe Graph::Group do

  before do
    @group = create :group
    @subgroup = @group.child_groups.create
    @user = create :user
    @membership = @subgroup.assign_user @user
  end

  describe "#descendant_member_ids" do
    subject { Graph::Group.find(@group).descendant_member_ids }
    it { should == [@user.id] }

    describe "when the group has current members" do
      before do
        @current_member = create :user
        @current_membership = @subgroup.assign_user @current_member, at: 2.years.ago
      end

      it { should include @current_member.id }

      describe "after destroying the membership" do
        before { @current_membership.destroy }
        it { should_not include @current_member.id }
      end
    end
    describe "when the group has past members" do
      before do
        @past_member = create :user
        @past_membership = @subgroup.assign_user @past_member, at: 10.years.ago
        @past_membership.update_attributes valid_to: 1.year.ago
      end

      it { should_not include @past_member.id }
    end
    describe "when the group has current members with limited memberships" do
      before do
        @current_member_with_limited_membership = create :user
        @current_but_limited_membership = @subgroup.assign_user @current_member_with_limited_membership, at: 10.years.ago
        @current_but_limited_membership.update_attributes valid_to: 1.year.from_now
      end

      it { should include @current_member_with_limited_membership.id }
    end

    describe "when the group has officers that are no regular members" do
      before do
        @officer_group = @group.create_officer_group name: "Officer"
        @officer_but_no_member = create :user
        @officer_but_no_member_membership = @officer_group.assign_user @officer_but_no_member
      end

      it "should not include the officer, which is no regular member of the group" do
        subject.should_not include @officer_but_no_member.id
      end
    end

    describe "when the group is an OfficerGroup" do
      before do
        @group = @group.create_officer_group name: "Officer"
        @officer_but_no_member = create :user
        @officer_but_no_member_membership = @group.assign_user @officer_but_no_member
      end

      it "should include the officer, which is no regular member of the parent group, because the request was to list the descendants of the officer group, e.g. when listing the officer-group memberships" do
        subject.should include @officer_but_no_member.id
      end
    end
  end

  describe "#descendant_group_ids" do
    subject { Graph::Group.find(@group).descendant_group_ids }
    it { should == [@subgroup.id] }

    describe "after destroying the subgroup" do
      before { @subgroup.destroy }
      it { should == [] }
    end
  end

  describe "#descendant_membership_ids" do
    subject { Graph::Group.find(@group).descendant_membership_ids }
    it { should == [@membership.id]}

    describe "when the group has officers that are no regular members" do
      before do
        @officer_group = @group.create_officer_group name: "Officer"
        @officer_but_no_member = create :user
        @officer_but_no_member_membership = @officer_group.assign_user @officer_but_no_member
      end

      it "should not include the officer, which is no regular member of the group" do
        subject.should_not include @officer_but_no_member_membership.id
      end
    end

    describe "when the group is an OfficerGroup" do
      before do
        @group = @group.create_officer_group name: "Officer"
        @officer_but_no_member = create :user
        @officer_but_no_member_membership = @group.assign_user @officer_but_no_member
      end

      it "should include the officer, which is no regular member of the parent group, because the request was to list the descendants of the officer group, e.g. when listing the officer-group memberships" do
        subject.should include @officer_but_no_member_membership.id
      end
    end
  end

  # describe "#descendant_event_ids" do
  #   subject { Graph::Group.find(@group).descendant_event_ids }
  #
  #   describe "when the group has direct events" do
  #     before { @event = @group.events.create name: "Some event" }
  #     it { should include @event.id }
  #   end
  #
  #   describe "when a subgroup has direct events" do
  #     before { @subgroup_event = @subgroup.events.create name: "Subgroup event" }
  #     it { should include @subgroup_event.id }
  #   end
  # end

end
