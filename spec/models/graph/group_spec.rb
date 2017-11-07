require 'spec_helper'

if Graph::Base.configured?
  describe Graph::Group do

    before do
      @group = create :group
      @subgroup = @group.child_groups.create
      @user = create :user
      @membership = @subgroup.assign_user @user
    end

    describe ".get_member_ids" do
      subject { Graph::Group.get_member_ids @group }
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
      subject { Graph::Group.get_descendant_group_ids @group }
      it { should == [@subgroup.id] }
    end

    describe ".get_membership_ids" do
      subject { Graph::Group.get_membership_ids @group }
      it { should == [@membership.id]}
    end

  end
end