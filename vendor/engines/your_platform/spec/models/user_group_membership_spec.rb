require 'spec_helper'

describe UserGroupMembership do


  before do
    @group = Group.create( name: "Group 1" )
    @super_group = Group.create( name: "Parent Group of Groups 1 and 2" )
    @other_group = Group.create( name: "Group 2" )
    @group.parent_groups << @super_group
    @other_group.parent_groups << @super_group
    @user = User.create( first_name: "John", last_name: "Doe", :alias => "j.doe" )
  end

  it "should allow to create example group and user and the group structure" do
    @user.should_not == nil
    @group.should_not == nil
    @super_group.should_not == nil
  end


  def create_membership
    UserGroupMembership.create( user: @user, group: @group )
  end

  def find_membership
    UserGroupMembership.find_by( user: @user, group: @group )
  end

  def find_membership_with_deleted
    UserGroupMembership.find_all_by( user: @user, group: @group ).with_deleted.first
  end

#  def create_indirect_membership
#    UserGroupMembership.create( user: @user, group: @super_group )
#  end

  def find_indirect_membership
    UserGroupMembership.find_by( user: @user, group: @super_group )
  end

  def find_indirect_membership_with_deleted
    UserGroupMembership.find_all_by( user: @user, group: @super_group ).with_deleted.first
  end

  def create_other_membership
    UserGroupMembership.create( user: @user, group: @other_group )
  end
  
  def find_other_membership
    UserGroupMembership.find_by( user: @user, group: @other_group )
  end

  def find_other_membership_with_deleted
    UserGroupMembership.find_all_by( user: @user, group: @other_group).with_deleted.first
  end

  def create_memberships
    create_membership
    create_other_membership
    # the indirect membership is created implicitly, becuase @group and @super_group are already connected.
  end

  # Creation Class Method
  # ====================================================================================================

  describe ".create" do
    it "should create a link between parent and child" do
      UserGroupMembership.create( user: @user, group: @group )
      @user.parents.should include( @group )
    end
    it "should raise an error if argument is missing" do
      expect { UserGroupMembership.create( user: @user ) }.should raise_error RuntimeError
      expect { UserGroupMembership.create( group: @group ) }.should raise_error RuntimeError
    end
  end

  # Finder Class Methods
  # ====================================================================================================

  describe "Finder Method" do
    before { create_memberships }

    describe ".find_all_by" do
      it "should find all memberships for a user" do
        UserGroupMembership.find_all_by( user: @user ).should include( find_membership )
        UserGroupMembership.find_all_by( user: @user ).should include( find_indirect_membership )
      end
      it "should find all memberships for a group" do
        UserGroupMembership.find_all_by( group: @group ).should include( find_membership )
      end
      it "should not find deleted memberships" do
        find_membership.destroy
        UserGroupMembership.find_all_by( user: @user )
          .should include( find_indirect_membership_with_deleted, find_other_membership_with_deleted )
        UserGroupMembership.find_all_by( user: @user )
          .should_not include( find_membership_with_deleted )
      end
    end
    describe ".find_all_by.with_deleted" do
      before { find_membership.destroy }
      it "should find all memberships, including the deleted ones" do
        UserGroupMembership.find_all_by( user: @user ).with_deleted
          .should include( find_membership_with_deleted, find_indirect_membership, find_other_membership )
      end
    end

    describe ".find_by" do
      it "should be the same as .find_by_all.first" do
        UserGroupMembership.find_by( user: @user, group: @group ).should ==
          UserGroupMembership.find_all_by( user: @user, group: @group ).first
      end
    end

    describe ".find_by_user_and_group" do
      it "should find the right membership" do
        UserGroupMembership.find_by_user_and_group( @user, @group ).should == find_membership
      end
    end

    describe ".find_all_by_user" do
      it "should find the right memberships" do
        UserGroupMembership.find_all_by_user( @user ).should include( find_membership )
      end
    end

    describe ".find_all_by_group" do
      it "should find the right memberships" do
        UserGroupMembership.find_all_by_group( @group ).should include( find_membership )
      end
    end
  end

  # Temporal Scope Methods
  # ====================================================================================================

  describe "#at_time( time )" do
    before { create_memberships }
    describe "with time being a point in the future" do
      it "should return the same membership, if it has no :deleted_at" do
        find_membership.deleted_at.should == nil
        find_membership.at_time( Time.current + 30.minutes ).should == find_membership
      end
      it "should return nil, if the membership ends before that time" do
        find_membership.destroy
        find_membership.should == nil
        find_membership_with_deleted.deleted_at.should_not == nil
        find_membership_with_deleted.at_time( Time.current + 30.minutes ).should == nil
      end
    end
    describe "with time being a point in the past" do
      it "should return nil, if the membership began after that time" do
        find_membership.should_not == nil
        find_membership.at_time( 30.minutes.ago ).should == nil
      end
      it "should return the same membership, if it has been created before that time" do
        find_membership.update_attributes( :created_at => 1.hour.ago )
        find_membership.created_at.should < 59.minutes.ago
        find_membership.at_time( 30.minutes.ago ).should == find_membership
      end
    end
  end

  # Save and Destroy Instance Methods
  # ====================================================================================================

  describe "#reload" do
    before { create_memberships }
    it "should restore the values from the database without saving" do
      membership = find_membership
      membership.created_at = 1.hour.ago
      membership.reload
      membership.created_at.should > 50.minutes.ago
    end
  end

  describe "#save" do
    before { create_memberships }
    describe "for direct memberships" do
      it "should save the membership itself" do
        membership = find_membership
        membership.created_at = 1.hour.ago
        membership.save
        find_membership.created_at.should < 50.minutes.ago
      end
    end
    describe "for indirect memberships" do
      it "should save the associated first_created_direct_membership as well" do
        indirect_membership = find_indirect_membership
        indirect_membership.first_created_direct_membership.created_at = 1.hour.ago
        indirect_membership.save
        find_membership.created_at.should < 50.minutes.ago
      end
      it "should save the associated last_deleted_direct_membership as well" do
        indirect_membership = find_indirect_membership
        indirect_membership.last_deleted_direct_membership.created_at = 1.hour.ago
        indirect_membership.save
        find_membership.created_at.should < 50.minutes.ago
      end
    end
  end

  describe "#destroy" do
    before { create_memberships }
    describe "for a direct membership" do
      it "should destroy the membership" do
        find_membership.present?.should be_true
        find_membership.destroy
        find_membership.present?.should be_false
      end
    end
    describe "for an indirect membership" do
      it "should destroy the direct memberships" do
        find_indirect_membership.present?.should be_true
        find_indirect_membership.destroy
        find_indirect_membership.present?.should be_false
        find_membership.present?.should be_false
      end
    end
  end

  describe "#delete!" do
    before { create_memberships } 
    describe "for direct links" do
      describe "for existing memberships" do
        it "should raise an error, since the database consistency would be desturbed without a proper destroy call" do
          expect { find_membership.delete! }.should raise_error RuntimeError
        end
      end
      describe "for memberships with #deleted_at not nil" do
        before { find_membership.destroy }
        it "should really delete the membership from the database" do
          find_membership_with_deleted.delete!
          find_membership_with_deleted.should be_nil
        end
      end
    end
  end


  # Status Instance Methods
  # ====================================================================================================

  describe "#present?" do
    before { create_membership }
    it "should be true if the membership exists" do
      find_membership.present?.should be_true
    end
    it "should be false if the membership does not exist" do
      find_membership.destroy
      find_membership.present?.should be_false
    end
  end

  describe "#deleted?" do
    it "should be false if the membership exists" do
      create_membership
      find_membership.deleted?.should be_false
    end
    it "should be true if the membership has been deleted" do
      create_membership
      find_membership.destroy
      find_membership.should == nil
      find_membership_with_deleted.deleted?.should be_true
    end
    it "should not be accessible if the membership never existed" do
      find_membership.should == nil
      find_membership_with_deleted.respond_to?( :deleted? ).should be_false
    end
  end

  describe "#destroyable?" do
    before { create_memberships }
    describe "for a direct membership" do
      subject { find_membership }
      its( :destroyable? ) { should be_true }
    end
    describe "for an indirect membership" do
      subject { find_indirect_membership }
      its( :destroyable? ) { should be_false }
    end
  end

  describe "#== ( other_membership ), i.e. euality relation, " do
    it "should return true if the two objects represent the same membership" do
      membership = create_membership
      same_membership = find_membership
      membership.should == same_membership
    end
  end


  # Timestamps Methods: Beginning and end of a membership
  # ====================================================================================================

  describe "#created_at" do
    it "should be the time of creation" do
      time_before_creation = Time.current
      create_membership
      find_membership.created_at.to_i.should >= time_before_creation.to_i
      find_membership.created_at.to_i.should <= Time.current.to_i
      # Note: to_i is necessary, since the elapsed time is too short to be recognized by a datetime string.
    end
    describe "for an indirect membership" do
      it "should return the datetime of the direct membership" do
        create_memberships
        find_membership.update_attributes( created_at: 1.hour.ago ) # assume the *direct* membership has been created earlier
        find_indirect_membership.created_at.should < 50.minutes.ago # ask for the *indirect* membership's :created_at
      end
    end
  end

  describe "#created_at=" do
    it "should set the time of creation, i.e. the beginning of the membership" do
      membership = create_membership
      membership.created_at = 1.hour.ago
      membership.save
      membership.created_at.to_i.should == 1.hour.ago.to_i
      membership.at_time( 30.minutes.ago ).present?.should be_true
      membership.at_time( Time.current + 30.minutes ).present?.should be_true
      membership.destroy
      membership = find_membership_with_deleted
      membership.at_time( Time.current + 30.minutes ).present?.should be_false
    end
    describe "for an indirect membership" do
      it "should modify the datetime of the direct membership" do
        create_memberships
        indirect_membership = find_indirect_membership
        indirect_membership.created_at = 1.hour.ago
        indirect_membership.save
        find_indirect_membership.created_at.should < 50.minutes.ago
      end
    end
  end

  describe "#deleted_at" do
    it "should be nil before deletion" do
      membership = create_membership
      membership.deleted_at.should == nil
    end
    it "should be the time of deletion" do
      membership = create_membership
      time_before_deletion = Time.current
      membership.destroy
      membership = find_membership_with_deleted
      membership.deleted_at.to_i.should >= time_before_deletion.to_i
      membership.deleted_at.to_i.should <= Time.current.to_i
    end
    describe "for an indirect membership" do
      it "should return the datetime of the direct membership" do
        create_membership
        find_membership.destroy
        find_membership_with_deleted.update_attributes( created_at: 2.hours.ago, deleted_at: 1.hour.ago )
        find_indirect_membership_with_deleted.deleted_at.should < 50.minutes.ago
      end
      specify "check boundary conditions, since this spec has previously caused problems" do
        create_membership
        find_other_membership.should == nil
        find_membership_with_deleted.deleted_at.should == nil
        find_indirect_membership_with_deleted.deleted_at.should == nil

        find_membership.destroy
        find_other_membership.should == nil
        find_membership.should == nil
        find_membership_with_deleted.should_not == nil
        find_membership_with_deleted.deleted_at.should_not == nil
        find_indirect_membership.should == nil
        find_indirect_membership_with_deleted.should_not == nil
        find_indirect_membership_with_deleted.direct?.should == false
        find_indirect_membership_with_deleted.direct_memberships_now
          .should_not include( find_membership_with_deleted )
        find_indirect_membership_with_deleted.direct_memberships_now_and_in_the_past
          .should include( find_membership_with_deleted )
        find_indirect_membership_with_deleted.deleted_at.should_not == nil
      end
    end
    describe "for an indirect membership of two direct memberships, where only one has been deleted" do
      it "should return nil, since the direct membership still persists" do
        create_memberships
        find_membership.destroy
        find_indirect_membership_with_deleted.deleted_at.should == nil
      end
      specify "check if the boundary conditions are fulfilled, since this spec has caused problems, previously" do
        create_memberships
        find_membership_with_deleted.deleted_at.should == nil
        find_other_membership_with_deleted.deleted_at.should == nil
        find_indirect_membership_with_deleted.deleted_at.should == nil

        find_membership.destroy
        find_membership_with_deleted.deleted_at.should_not == nil
        find_other_membership_with_deleted.deleted_at.should == nil
        find_indirect_membership_with_deleted.deleted_at.should == nil
      end
    end
  end

  describe "#deleted_at=" do
    it "should set the time of deletion, i.e. the termination of the membership" do
      membership = create_membership
      membership.destroy
      membership = find_membership_with_deleted
      membership.deleted_at = Time.current + 1.hour
      membership.save
      membership.at_time( Time.current + 30.minutes ).present?.should be_true
      membership.at_time( Time.current + 2.hours ).present?.should be_false
    end
    describe "for an indirect membership" do
      it "should modify the datetime of the direct membership" do
        create_membership
        find_membership.destroy
        find_membership_with_deleted.update_attributes( created_at: 2.hours.ago )
        indirect_membership = find_indirect_membership_with_deleted
        indirect_membership.deleted_at = 1.hour.ago
        indirect_membership.save
        find_membership_with_deleted.deleted_at.should < 50.minutes.ago
      end
    end
    describe "for an indirect membership of two direct memberships, where only one has been deleted" do
      it "still persists. Therefore, setting :deleted_at doesn't make sense." do
        create_memberships
        find_membership.destroy
        find_indirect_membership.present?.should be_true
      end
    end
  end

  describe "#created_at_date" do
    before { @membership = create_membership }
    subject { @membership.created_at_date }
    it "should return the date of creation" do
      subject.should == @membership.created_at.to_date
    end
  end
  describe "#created_at_date=" do
    before do
      @membership = create_membership 
      @new_created_at = 1.year.ago
      @new_created_at_date = @new_created_at.to_date
    end
    subject { @membership.created_at_date = @new_created_at_date }
    it "should set the create_at value correctly" do
      subject
      @membership.created_at_date.should == @new_created_at_date
      @membership.created_at.to_date.should == @new_created_at_date
    end
  end
  describe "#created_at_date_formatted" do
    before { @membership = create_membership }
    subject { @membership.created_at_date_formatted }
    it "should return a string" do
      subject.should be_kind_of String
    end
    it "should return the localized date of creation" do
      subject.should == I18n.localize( @membership.created_at.to_date )
    end
  end
  describe "#created_at_date_formatted=" do
    before do
      @membership = create_membership
      @new_created_at = 1.year.ago
      @new_created_at_formatted = I18n.localize( @new_created_at.to_date )
    end
    subject { @membership.created_at_date_formatted = @new_created_at_formatted }
    it "should set the created_at value correctly" do
      subject
      @membership.created_at_date_formatted.should == @new_created_at_formatted
      @membership.created_at_date.should == @new_created_at.to_date
      @membership.created_at.to_date.should == @new_created_at.to_date
    end
  end



  # Access Methods to Associated User and Group
  # ====================================================================================================

  describe "Access Method to Assiciation" do
    before { create_membership }
    subject { find_membership }

    describe "#user" do
      its( :user ) { should == @user }
    end

    describe "#group" do
      its( :group ) { should == @group }
    end
  end


  # Associated Corporation
  # ====================================================================================================

  # corporation
  #     |-------- group
  #                 |---( membership )---- user
  #
  describe "#corporation" do
    describe "for the group having a corporation" do
      before do
        @corporation = create( :corporation )
        @group = @corporation.child_groups.create
        @user = create( :user )
        @group.assign_user @user
      end
      subject { UserGroupMembership.find_by_user_and_group( @user, @group ).corporation }
      it { should == @corporation }
    end
    describe "for the group not having a corporation" do
      before do
        @group = create( :group )
        @user = create( :user )
        @group.assign_user @user
      end
      subject { UserGroupMembership.find_by_user_and_group( @user, @group ).corporation }
      it { should == nil }
    end
    describe "for the group being a corporation" do
      before do
        @corporation = create( :corporation )
        @user = create( :user )
        @corporation.assign_user @user
      end
      subject { UserGroupMembership.find_by_user_and_group( @user, @corporation ).corporation }
      it { should == @corporation }
    end
  end



  # Access Methods to Associated Direct Memberships
  # ====================================================================================================

  describe "#direct_memberships" do
    before {create_memberships }
    describe "for a direct membership" do
      subject { find_membership }
      it "should include only itself (the direct membership)" do
        subject.direct_memberships.should == [ subject ]
      end
    end
    describe "for an indirect membership" do
      subject { find_indirect_membership }
      it "should include the direct membership" do
        subject.direct_memberships.should include( find_membership )
      end
    end
  end

  describe "#direct_memberships_now_and_in_the_past" do
    before { create_memberships }
    it "should return an ActiveRecord::Relation, i.e. be chainable" do
      find_membership.direct_memberships_now_and_in_the_past.kind_of?( ActiveRecord::Relation ).should be_true
    end
    it "should be the same as #direct_memberships.now_and_in_the_past" do
      find_indirect_membership.direct_memberships_now_and_in_the_past.should ==
        find_indirect_membership.direct_memberships.now_and_in_the_past
    end
    describe "for a direct membership" do
      it "should include itself (the direct membership)" do
        find_membership.direct_memberships_now_and_in_the_past.should include( find_membership )
      end
    end
    describe "for an indirect membership" do
      it "should include the direct membership" do
        find_indirect_membership.direct_memberships_now_and_in_the_past.should include( find_membership )
      end
    end
  end

  describe "#direct_groups" do
    before { create_memberships }
    describe "for a direct membership" do
      it "should return an array containing only the own group" do
        find_membership.direct_groups.should == [ find_membership.group ]
      end
    end
    describe "for an indirect membership" do
      it "should return an array containing the direct group" do
        find_indirect_membership.direct_groups.should == [ find_membership.group, find_other_membership.group ]
      end
    end
  end

  describe "#first_created_direct_membership" do
    before do
      @user = create(:user)

      # The @user will be indirect member of these corporations:
      @corporationE = create( :corporation_with_status_groups, :token => "E" )
      @corporationH = create( :corporation_with_status_groups, :token => "H" )

      # The @user will be direct member of these status groups, which are subgroups of the corporations:
      @first_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.first )
      @first_membership_E.update_attributes( created_at: "2006-12-01".to_datetime )
      @first_membership_H = StatusGroupMembership.create( user: @user, group: @corporationH.status_groups.first )
      @first_membership_H.update_attributes( created_at: "2008-12-01".to_datetime )
      @first_membership_E.destroy
      @second_membership_E = StatusGroupMembership.create( user: @user, group: @corporationE.status_groups.last )
      @second_membership_E.update_attributes( created_at: "2013-12-01".to_datetime )

      @membershipE = UserGroupMembership.find_by_user_and_group(@user, @corporationE)
    end
    subject { @membershipE.first_created_direct_membership }
    
    specify "verify which memberships are direct and which are indirect" do
      @membershipE.direct?.should == false
      @first_membership_E.reload.direct?.should == true
      @second_membership_E.reload.direct?.should == true
      @first_membership_H.reload.direct?.should == true
    end
  
    it "should return the direct sub-membership, which has been created first" do
      subject.should == @first_membership_E.becomes(UserGroupMembership)
    end
  end

  describe "#last_deleted_direct_membership" do
    before do
      create_memberships
      find_membership.destroy
      sleep 1.2 # in order to be able to discriminate the two datetimes
      find_other_membership.destroy
    end
    subject { find_indirect_membership_with_deleted.last_deleted_direct_membership }
    it { should == find_other_membership_with_deleted }
  end


  # More Tests for Indirect Memberships
  # ====================================================================================================

  describe "Indirect Membership" do

    before do
      @sub_group = Group.create( name: "Sub Group" )
      @sub_group.parent_groups << @group
      @user.parent_groups << @sub_group
      @membership = UserGroupMembership.find_by_user_and_group( @user, @sub_group )
      @indirect_membership = UserGroupMembership.find_by_user_and_group( @user, @group )
    end

    subject { @indirect_membership }

    it "should have the same date of creation as the direct membership" do
      @indirect_membership.created_at.should == @membership.created_at
    end

    it "should have the same date of deletion as the direct membership" do
      @indirect_membership.deleted_at.should == @membership.deleted_at
    end

    it "should also effect the direct membership on change of date of creation" do
      new_time = 1.hour.ago
      @membership.created_at = new_time
      @membership.save
      @indirect_membership.created_at.to_i.should == new_time.to_i
    end

    it "should also effect the direct membership on change of date of deletion" do
      new_time = Time.current + 1.hour
      @membership.destroy
      @membership.deleted_at = new_time
      @membership.save
      @indirect_membership.reload
      @indirect_membership.deleted_at.to_i.should == new_time.to_i
    end

    it "should be effected by the direct membership on change of date of creation" do
      new_time = 1.hour.ago
      @indirect_membership.created_at = new_time
      @indirect_membership.save
      @membership.reload
      @membership.created_at.to_i.should == new_time.to_i
    end

    it "should be effected by the direct membership on change of date of deletion" do
      new_time = Time.current + 1.hour
      @membership.destroy # need to destroy the *direct* membership, ...
      @indirect_membership.reload
      @indirect_membership.deleted_at = new_time # but can change the time of the *indirect*.
      @indirect_membership.save
      @membership.reload
      @membership.deleted_at.to_i.should == new_time.to_i
    end
  end

  # Methods to Change the Membership
  # ====================================================================================================       

  describe "#move_to_group( group )" do
    before do
      create_membership
      find_membership.move_to_group( @other_group )
    end
    it "should destroy the direct membership" do
      find_membership.should == nil
    end
    it "should create a new membership between the user and the given group" do
      find_other_membership.should_not == nil
    end
  end
  
end
