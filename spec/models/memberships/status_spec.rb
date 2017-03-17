require 'spec_helper'

describe Memberships::Status do

  describe "(status workflow scenario) (bug fix)" do

    before do
      @user = create(:user)
      @corporation = create(:corporation_with_status_groups)
      @status_groups = @corporation.status_groups

      @first_status_group = @status_groups.first
      @second_status_group = @status_groups.second

      @first_status_group.assign_user @user

      @first_promotion_workflow = create :promotion_workflow, name: 'First Promotion',
          remove_from_group_id: @first_status_group.id, add_to_group_id: @second_status_group.id
      @first_promotion_workflow.parent_groups << @first_status_group
    end

    def status_memberships_of_user_and_corporation
      Memberships::Status.find_all_by_user_and_corporation(@user, @corporation).with_past
    end
    def first_status_membership
      Memberships::Status.with_past.find_by_user_and_group(@user, @first_status_group)
    end
    def second_status_membership
      Memberships::Status.with_past.find_by_user_and_group(@user, @second_status_group)
    end

    describe "prelims" do
      specify "first_status_membership should find the membership even if invalidated" do
        first_status_membership.should_not == nil
        first_status_membership.invalidate at: 1.hour.ago
        first_status_membership.should_not == nil
      end
    end

    describe "executing the first promotion workflow" do
      subject { @first_promotion_workflow.execute(user_id: @user.id); @user.reload }
      it "should add the second status group to the user's status groups" do
        status_memberships_of_user_and_corporation.should_not include second_status_membership
        subject
        status_memberships_of_user_and_corporation.should include second_status_membership
      end
      it "should not remove the first status group from the user's status groups" do
        status_memberships_of_user_and_corporation.should include first_status_membership
        subject
        status_memberships_of_user_and_corporation.should include first_status_membership
      end
    end

  end


end