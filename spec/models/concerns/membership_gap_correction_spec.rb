require 'spec_helper'

describe MembershipGapCorrection do

  before do
    @group = create :group
    @status1 = @group.child_groups.create name: "Status 1"
    @status2 = @group.child_groups.create name: "Status 2"
    @user = create :user

    @time1 = 1.year.ago
    @time2 = 1.month.ago
    @time3 = 3.days.ago

    @membership1 = @status1.assign_user @user, at: @time1
    @membership2 = @status2.assign_user @user, at: @time2
    @status2.unassign_user @user, at: @time3
  end

  describe ".apply_gap_correction" do
    subject { Membership.apply_gap_correction(@user, @group) }

    it "should preserve the valid_from of the left-most membership" do
      @membership1.reload.valid_from.should be_the_same_time_as @time1
      subject
      @membership1.reload.valid_from.should be_the_same_time_as @time1
    end
    it "should correct the valid_to of the left-most membership" do
      @membership1.valid_to.should == nil
      subject
      @membership1.reload.valid_to.should be_the_same_time_as @time2
    end
    it "should preserve the valid_from of middle memberships" do
      @membership2.reload.valid_from.should be_the_same_time_as @time2
      subject
      @membership2.reload.valid_from.should be_the_same_time_as @time2
    end
    it "should preserve the valid_to of the right membership" do
      @membership2.reload.valid_to.should be_the_same_time_as @time3
      subject
      @membership2.reload.valid_to.should be_the_same_time_as @time3
    end

    specify "at the cut point, there should by only one membership" do
      subject
      @user.memberships.direct.with_past.at_time(@time2).count.should be_the_same_time_as 1
    end

    describe "for nested group structures" do
      before do
        @middle_group = @group.child_groups.create name: "This group is inbetween group and status 3"
        @status3 = @middle_group.child_groups.create name: "Status 3"
        @time4 = 2.days.ago
        @membership3 = @status3.assign_user @user, at: @time4
      end

      it "should consider the nested status group when applying the gap correction" do
        @membership2.reload.valid_to.should be_the_same_time_as @time3
        subject
        @membership2.reload.valid_to.should be_the_same_time_as @time4
      end
    end

  end

  describe "for corporations and status groups" do
    before do
      @corporation = create :corporation_with_status_groups
      @status1 = @corporation.status_groups.first
      @status2 = @corporation.status_groups.second

      @membership1 = @status1.assign_user @user, at: @time1
      @membership2 = @status2.assign_user @user, at: @time2
      @status2.unassign_user @user, at: @time3
    end

    describe "#apply_gap_correction" do
      subject { @membership2.apply_gap_correction }

      it "should preserve the valid_from of the left-most membership" do
        @membership1.reload.valid_from.should be_the_same_time_as @time1
        subject
        @membership1.reload.valid_from.should be_the_same_time_as @time1
      end
      it "should correct the valid_to of the left-most membership" do
        @membership1.valid_to.should == nil
        subject
        @membership1.reload.valid_to.should be_the_same_time_as @time2
      end
      it "should preserve the valid_from of middle memberships" do
        @membership2.reload.valid_from.should be_the_same_time_as @time2
        subject
        @membership2.reload.valid_from.should be_the_same_time_as @time2
      end
    end

    describe "for being a status-group officer" do
      before do
        @status3 = @corporation.status_groups[2]
        @status3_office = @status3.create_officer_group name: "Secretary of status 3"
        @status3_office.assign_user @user, at: 4.days.ago
      end

      it "should not consider the indirect membership of status3 as the user is only officer there, no regular member" do
        @membership2.reload.valid_to.should be_the_same_time_as @time3
        subject
        @membership2.reload.valid_to.should be_the_same_time_as @time3
      end
    end

  end

end