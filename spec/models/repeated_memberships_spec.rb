require 'spec_helper'

describe Membership do

  before do
    @group = create :group
    @user = create :user

    # ----------------- t1 -- t2 -- t3 -- t4 -- t5 -- t6 -----------------> time
    # membership1              ......
    # membership2                          ......
    @t0 = 10.years.ago
    @t1 = @t0 + 1.year
    @t2 = @t0 + 2.years
    @t3 = @t0 + 3.years
    @t4 = @t0 + 4.years
    @t5 = @t0 + 5.years
    @t6 = @t0 + 6.years
    @delta_t = 1.day

    @membership1 = @group.assign_user @user, at: @t2
    @membership1.update valid_to: @t3

    @membership2 = @group.assign_user @user, at: @t4
    @membership2.update valid_to: @t5
  end

  describe "Group#memberships#with_past" do
    specify { @group.memberships.with_past.count.should == 2 }
  end

  describe "Group#memberships#at_time" do
    specify { @group.memberships.at_time(@t1).count.should == 0 }
    specify { @group.memberships.at_time(@t2 + @delta_t).count.should == 1 }
    specify { @group.memberships.at_time(@t3 + @delta_t).count.should == 0 }
    specify { @group.memberships.at_time(@t4 + @delta_t).count.should == 1 }
    specify { @group.memberships.at_time(@t6).count.should == 0 }
  end

  describe "indirect memberships" do
    before do
      run_background_jobs
      @super_group = create :group
      @super_group << @group
    end

    describe "before the background jobs have run" do
      describe "Group#memberships#with_past" do
        specify { @super_group.memberships.with_past.count.should == 0 }
      end

      describe "Group#memberships#at_time" do
        specify { @super_group.memberships.at_time(@t1).count.should == 0 }
        specify { @super_group.memberships.at_time(@t2 + @delta_t).count.should == 0 }
        specify { @super_group.memberships.at_time(@t3 + @delta_t).count.should == 0 }
        specify { @super_group.memberships.at_time(@t4 + @delta_t).count.should == 0 }
        specify { @super_group.memberships.at_time(@t6).count.should == 0 }
      end
    end

    describe "after the background jobs have run" do
      before { run_background_jobs }

      describe "Group#memberships#with_past" do
        specify { @super_group.memberships.with_past.count.should == 2 }
      end

      describe "Group#memberships#at_time" do
        specify { @super_group.memberships.at_time(@t1).count.should == 0 }
        specify { @super_group.memberships.at_time(@t2 + @delta_t).count.should == 1 }
        specify { @super_group.memberships.at_time(@t3 + @delta_t).count.should == 0 }
        specify { @super_group.memberships.at_time(@t4 + @delta_t).count.should == 1 }
        specify { @super_group.memberships.at_time(@t6).count.should == 0 }
      end
    end

    describe "after removing a group-group link" do
      before do
        run_background_jobs
        @super_group.child_groups.destroy(@group)
      end

      describe "before the background jobs have run" do
        describe "Group#memberships#with_past" do
          specify { @super_group.memberships.with_past.count.should == 2 }
        end

        describe "Group#memberships#at_time" do
          specify { @super_group.memberships.at_time(@t1).count.should == 0 }
          specify { @super_group.memberships.at_time(@t2 + @delta_t).count.should == 1 }
          specify { @super_group.memberships.at_time(@t3 + @delta_t).count.should == 0 }
          specify { @super_group.memberships.at_time(@t4 + @delta_t).count.should == 1 }
          specify { @super_group.memberships.at_time(@t6).count.should == 0 }
        end
      end

      describe "after the background jobs have run" do
        before { run_background_jobs }

        describe "Group#memberships#with_past" do
          specify { @super_group.memberships.with_past.count.should == 0 }
        end

        describe "Group#memberships#at_time" do
          specify { @super_group.memberships.at_time(@t1).count.should == 0 }
          specify { @super_group.memberships.at_time(@t2 + @delta_t).count.should == 0 }
          specify { @super_group.memberships.at_time(@t3 + @delta_t).count.should == 0 }
          specify { @super_group.memberships.at_time(@t4 + @delta_t).count.should == 0 }
          specify { @super_group.memberships.at_time(@t6).count.should == 0 }
        end
      end
    end

    describe "2nd-order indirect memberships" do
      before do
        run_background_jobs
        @super_super_group = create :group
        @super_super_group << @super_group
      end

      describe "after the background jobs have run" do
        before { run_background_jobs }

        describe "Group#memberships#with_past" do
          specify { @super_super_group.memberships.with_past.count.should == 2 }
        end

        describe "Group#memberships#at_time" do
          specify { @super_super_group.memberships.at_time(@t1).count.should == 0 }
          specify { @super_super_group.memberships.at_time(@t2 + @delta_t).count.should == 1 }
          specify { @super_super_group.memberships.at_time(@t3 + @delta_t).count.should == 0 }
          specify { @super_super_group.memberships.at_time(@t4 + @delta_t).count.should == 1 }
          specify { @super_super_group.memberships.at_time(@t6).count.should == 0 }
        end
      end
    end
  end


end