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
      @membership1.reload.valid_from.should == @time1
      subject
      @membership1.reload.valid_from.should == @time1
    end
    it "should correct the valid_to of the left-most membership" do
      @membership1.valid_to.should_not == @time2
      subject
      @membership1.reload.valid_to.should == @time2
    end
    it "should preserve the valid_from of middle memberships" do
      @membership2.reload.valid_from.should == @time2
      subject
      @membership2.reload.valid_from.should == @time2
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
        @membership1.reload.valid_from.should == @time1
        subject
        @membership1.reload.valid_from.should == @time1
      end
      it "should correct the valid_to of the left-most membership" do
        @membership1.valid_to.should_not == @time2
        subject
        @membership1.reload.valid_to.should == @time2
      end
      it "should preserve the valid_from of middle memberships" do
        @membership2.reload.valid_from.should == @time2
        subject
        @membership2.reload.valid_from.should == @time2
      end
    end
  end

end