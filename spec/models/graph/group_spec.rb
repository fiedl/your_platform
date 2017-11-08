require 'spec_helper'

if Graph::Base.configured?
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
    end

    describe ".get_descendant_group_ids" do
      subject { Graph::Group.find(@group).descendant_group_ids }
      it { should == [@subgroup.id] }
    end

    describe ".get_membership_ids" do
      subject { Graph::Group.find(@group).descendant_membership_ids }
      it { should == [@membership.id]}
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
end