# We had some issues with memberships losing their validity ranges.
# https://trello.com/c/VvY1q6Cs/1127-validity-ranges-spielen-verruckt
#
# This spec has to make sure that the validity ranges of indirect
# membersips do not vanish for graph operations.

require 'spec_helper'

describe Membership do

  before do
    @corporation1 = create :corporation_with_status_groups
    @corporation2 = create :corporation_with_status_groups
    @superstatus1 = create :group; @superstatus1 << @corporation1.status_groups.first; @superstatus1 << @corporation2.status_groups.first
    @superstatus2 = create :group; @superstatus2 << @corporation1.status_groups.second; @superstatus2 << @corporation2.status_groups.second
    @user1 = create :user
    membership1 = @corporation1.status_groups.first.assign_user @user1, at: (@time1 = 50.years.ago)
    membership2 = @corporation2.status_groups.first.assign_user @user1, at: (@time2 = 49.years.ago)
    membership1.move_to @corporation1.status_groups.second, at: (@time3 = 45.years.ago)
    membership2.move_to @corporation2.status_groups.second, at: (@time4 = @time3 + 1.year)
  end

  specify "The indirect validity ranges should match the direct ones" do
    Membership.with_invalid.find_by_user_and_group(@user1, @superstatus1).valid_from.year.should == @time1.year
    Membership.with_invalid.find_by_user_and_group(@user1, @superstatus1).valid_to.year.should == @time4.year
    Membership.with_invalid.find_by_user_and_group(@user1, @superstatus2).valid_from.year.should == @time3.year
    Membership.with_invalid.find_by_user_and_group(@user1, @superstatus2).valid_to.should == nil
  end

  describe "DagLink.repair" do
    before { DagLink.repair }
    specify "The indirect validity ranges should match the direct ones" do
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus1).valid_from.year.should == @time1.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus1).valid_to.year.should == @time4.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus2).valid_from.year.should == @time3.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus2).valid_to.should == nil
    end
  end

  describe "DagLink.recalculate_indirect_validity_ranges" do
    before { DagLink.recalculate_indirect_validity_ranges }
    specify "The indirect validity ranges should match the direct ones" do
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus1).valid_from.year.should == @time1.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus1).valid_to.year.should == @time4.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus2).valid_from.year.should == @time3.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus2).valid_to.should == nil
    end
  end

  describe "RenewCacheJob(direct membership)" do
    before { RenewCacheJob.perform_later(Membership.find_by_user_and_group(@user1, @corporation1.status_groups.first)) }
    specify "The indirect validity ranges should match the direct ones" do
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus1).valid_from.year.should == @time1.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus1).valid_to.year.should == @time4.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus2).valid_from.year.should == @time3.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus2).valid_to.should == nil
    end
  end

  describe "RenewCacheJob(indirect membership)" do
    before { RenewCacheJob.perform_later(Membership.find_by_user_and_group(@user1, @superstatus1)) }
    specify "The indirect validity ranges should match the direct ones" do
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus1).valid_from.year.should == @time1.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus1).valid_to.year.should == @time4.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus2).valid_from.year.should == @time3.year
      Membership.with_invalid.find_by_user_and_group(@user1, @superstatus2).valid_to.should == nil
    end
  end
end