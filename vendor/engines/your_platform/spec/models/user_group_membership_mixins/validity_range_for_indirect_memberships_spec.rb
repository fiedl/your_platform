require 'spec_helper'

describe UserGroupMembershipMixins::ValidityRangeForIndirectMemberships do

  # Memberships:
  #
  #       *-----------------(c)--------------------*
  #                          |
  #                |--------------------|
  #                |                    |
  #       *-------(a)--------*          | 
  #                          *---------(b)---------*
  #
  #       _________________________________________________________
  #       t1                 t2                    t3      time -->
  #
  # Structure:
  #
  #       indirect_group ........................... (c)
  #             |---------- direct_group ........... (a), (b)
  #                              |--------- user
  #       
  before do
    @user = create(:user)
    @indirect_group = create(:group)
    @direct_group_a = @indirect_group.child_groups.create
    @direct_group_b = @indirect_group.child_groups.create    
    @direct_group_a.assign_user @user
    @indirect_membership = UserGroupMembership.find_by_user_and_group(@user, @indirect_group)
    @direct_membership_a = UserGroupMembership.find_by_user_and_group(@user, @direct_group_a)
    @direct_membership_b = @direct_membership_a.move_to_group(@direct_group_b)
    @t1 = 2.hours.ago
    @t2 = 1.hour.ago
    @t3 = nil
    @direct_membership_a.update_attribute(:valid_from, @t1)
    @direct_membership_a.update_attribute(:valid_to, @t2)
    @direct_membership_b.update_attribute(:valid_from, @t2)
    @direct_membership_b.update_attribute(:valid_to, @t3)
  end
  
  specify "preliminaries" do
    @direct_membership_a.valid_from.to_i.should < @direct_membership_b.valid_from.to_i
    
    #@direct_membership_a.valid_to.should < @direct_membership_b.valid_to
  end
  
  
  # Validity Range Attributes
  # ====================================================================================================
  
  describe "#valid_from" do
    subject { @indirect_membership.valid_from }
    it "should be the valid_from attribute of the earliest direct membership" do
      subject.to_i.should == @direct_membership_a.valid_from.to_i
    end
  end
  describe "#valid_from=" do
    before { @time = 30.minutes.ago }
    subject { @indirect_membership.valid_from = @time }
    it "should set the valid_from  attribute of the earliset direct membership" do
      subject
      @indirect_membership.save
      @direct_membership_a.reload.valid_from.to_i.should == @time.to_i
    end
  end
  
  describe "#valid_to" do
    subject { @indirect_membership.valid_to }
    it "should be the valid_to attribute of the latest direct membership" do
      subject.to_i.should == @direct_membership_b.valid_to.to_i
    end
  end
  describe "#valid_to=" do
    before { @time = 30.minutes.ago }
    subject { @indirect_membership.valid_to = @time }
    it "should set the valid_to addtirbute of the last direct membership" do
      subject
      @indirect_membership.save
      @direct_membership_b.reload.valid_to.to_i.should == @time.to_i
    end
  end
  
  describe "#earliest_direct_membership" do
    subject { @indirect_membership.earliest_direct_membership }
    it { should == @direct_membership_a }
  end
  
  describe "#latest_direct_membership" do
    subject { @indirect_membership.latest_direct_membership }
    it { should == @direct_membership_b }
  end
  
  describe "#recalculate_validity_range_from_direct_memberships" do
    before do
      @t1 = 10.hours.ago; @t2 = 8.hours.ago; @t3 = 37.minutes.ago
      @direct_membership_a.update_attribute(:valid_from, @t1)
      @direct_membership_a.update_attribute(:valid_to, @t2)
      @direct_membership_b.update_attribute(:valid_from, @t2)
      @direct_membership_b.update_attribute(:valid_to, @t3)
    end
    subject { @indirect_membership.recalculate_validity_range_from_direct_memberships }
    it "should make the indirect validity range match the direct memberships' combined range" do
      subject
      @indirect_membership.valid_from.to_i.should == @t1.to_i
      @indirect_membership.valid_to.to_i.should == @t3.to_i
    end
    it "should write the indirect ranges to the database" do
      subject
      @indirect_membership.read_attribute(:valid_from).to_i.should == @t1.to_i
      @indirect_membership.read_attribute(:valid_to).to_i.should == @t3.to_i
    end
    it "should persist in the graph" do
      subject
      DagLink.find(@indirect_membership.id).valid_from.to_i.should == @t1.to_i
      DagLink.find(@indirect_membership.id).valid_to.to_i.should == @t3.to_i
    end
    describe "for the earliest valid_from being nil" do
      before { @direct_membership_a.update_attribute(:valid_from, nil) }
      specify "prelims" do
        @reloaded_direct_membership_a = UserGroupMembership.with_invalid.find(@direct_membership_a.id)
        @reloaded_direct_membership_a.read_attribute(:valid_from).should == nil
      end
      it "should set the indirect valid_from to nil" do
        subject
        @indirect_membership.read_attribute(:valid_from).should == nil
      end
    end
    describe "(bug fix: reproducing status group membership scenario)" do
      #   @corporation
      #        |------- @intermediate_group
      #                         |------------ @status_group
      #                         |                  |--------- (@user)
      #                         | 
      #                         |------------ @second_status_group
      #                                            |--------- @user
      before do
        @corporation = create( :corporation, name: "Corporation" )
        @intermediate_group = create( :group, name: "Not a Status Group" )
        @status_group = create( :group, name: "Status Group" )
        @intermediate_group.parent_groups << @corporation
        @status_group.parent_groups << @intermediate_group
        @user = create( :user )
        @status_group.assign_user @user
        @membership = UserGroupMembership.find_by_user_and_group( @user, @status_group )
        @intermediate_group_membership = UserGroupMembership
          .find_by_user_and_group( @user, @intermediate_group )
        @second_status_group = @intermediate_group.child_groups.create(name: "Second Status Group")
        @membership.update_attribute(:valid_from, 1.year.ago)
        @corpo_membership = UserGroupMembership.find_by_user_and_group(@user, @corporation)
      end
      specify "prelims" do
        @user.should be_kind_of User
        @corporation.should be_kind_of Corporation
        @corporation.descendants.should include @intermediate_group, @status_group, @second_status_group, @user
        @intermediate_group.descendants.should include @status_group, @second_status_group, @user
        @status_group.descendants.should include @user
      end
      describe "promoting the membership" do
        subject { @second_membership = @membership.move_to(@second_status_group, at: 20.day.ago) }
        # @membership          valid_from: 1.year.ago,   valid_to: 20.days.ago
        # @second_membership   valid_from: 20.days.ago,  valid_to: nil
        # @corpo_membership    valid_from: 1.year.ago,   valid_to: nil
        before { subject }

        it "should update the valid_from and valid_to of the indirect membership" do
          @corpo_membership.read_attribute(:valid_from).to_date.should == 1.year.ago.to_date
          @corpo_membership.read_attribute(:valid_to).should == nil
        end
        it "should update the validity range persistent" do
          @reloaded_corpo_membership = UserGroupMembership.find(@corpo_membership.id)
          @reloaded_corpo_membership.should == @corpo_membership
          @reloaded_corpo_membership.valid_from.to_date.should == 1.year.ago.to_date
          @reloaded_corpo_membership.valid_to.should == nil
        end
        it "should update the valid_from and valid_to of the corresponding graph link" do
          @link = DagLink.find(@corpo_membership.id)
          @link.valid_from.to_date.should == 1.year.ago.to_date
          @link.valid_to.should == nil
        end
        it "should update the graph structure" do
          @second_status_group.descendants.should include @user
          @corporation.descendants.should include @user
        end
        it "should update the corporation members correctly" do
          @corporation.members.should include @user
          @user.should be_member_of @corporation
        end
        specify "the corporation members should match the memberships in number" do
          @corporation.memberships.count.should > 0
          @corporation.memberships.count.should == @corporation.members.count
        end
        specify "the indirect membership should be included in the memberships associated with the corporation" do
          @corporation.memberships.should include @corpo_membership
        end
        it "should make no difference if the validity range is forcefully updated" do
          @corpo_membership.read_attribute(:valid_from).to_date.should == 1.year.ago.to_date
          @corpo_membership.read_attribute(:valid_to).should == nil

          @membership.update_attribute(:valid_from, 1.year.ago)
          @membership.update_attribute(:valid_to, 20.days.ago)
          @second_membership.update_attribute(:valid_from, 20.days.ago)
          @second_membership.update_attribute(:valid_to, nil)

          @corpo_membership = UserGroupMembership.find(@corpo_membership.id)
          @corpo_membership.read_attribute(:valid_from).to_date.should == 1.year.ago.to_date
          @corpo_membership.read_attribute(:valid_to).should == nil
        end
      end
    end
  end
  
    
  # Invalidation
  # ====================================================================================================
  
  describe "#make_invalid" do
    subject { @indirect_membership.make_invalid }
    it "should raise an error" do
      expect { subject }.to raise_error
    end
  end
  describe "#invalidate" do
    subject { @indirect_membership.invalidate }
    it "should raise an error" do
      expect { subject }.to raise_error
    end
  end

  
  # Validity Check
  # ====================================================================================================
  
  describe "#valid_at?(time)" do
    subject { @indirect_membership.valid_at? @time_to_check }
    specify "preliminaries" do
      @indirect_membership.earliest_direct_membership.valid_from.to_i.should == @t1.to_i
      @indirect_membership.earliest_direct_membership.valid_to.to_i.should == @t2.to_i
      @indirect_membership.latest_direct_membership.valid_from.to_i.should == @t2.to_i
      @indirect_membership.latest_direct_membership.valid_to.should == @t3
    end
    it "should return false before the early direct membership" do
      @time_to_check = 3.hours.ago
      subject.should == false
    end
    it "should return true for the duration of the early direct membership" do
      @time_to_check = 1.5.hours.ago
      subject.should == true
    end
    it "should return true for the duration of the late direct membership" do
      @time_to_check = 0.5.hours.ago
      subject.should == true
    end
  end
  
  
  # Temporal scopes
  # ====================================================================================================
  
  describe "#at_time" do
    subject { UserGroupMembership.find_all_by_user(@user).at_time(30.minutes.ago) }
    specify "preliminaries" do
      @direct_membership_a.valid_from.to_i.should == @t1.to_i
      @direct_membership_a.valid_to.to_i.should == @t2.to_i
      @direct_membership_b.valid_from.to_i.should == @t2.to_i
      @direct_membership_b.valid_to.should == @t3
      @indirect_membership.valid_from.to_i.should == @t1.to_i
      @indirect_membership.valid_to.should == @t3
      # @indirect_membership.read_attribute(:valid_from).to_i.should == @t1.to_i
      # @indirect_membership.read_attribute(:valid_to).should == @t3
    end
    it "should find the direct membership" do
      subject.should include @direct_membership_b
    end
    it "should find the indirect membership as well" do
      subject.should include @indirect_membership
    end
  end
  
  describe "#only_valid" do
    subject { UserGroupMembership.only_valid.find_all_by_user(@user) }
    it "should find the valid indirect memberships" do
      subject.should include @indirect_membership
    end
    it "should not find the invalid indirect memberships" do
      @direct_membership_b.invalidate at: 20.minutes.ago
      subject.should_not include @indirect_membership
    end
  end
  

end
