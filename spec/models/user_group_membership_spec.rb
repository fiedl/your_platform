require 'spec_helper'

describe UserGroupMembership do


  before do
    @group = Group.create( name: "Group 1" )
    @super_group = Group.create( name: "Parent Group of Group 1" )
    @group.parent_groups << @super_group
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

  def create_indirect_membership
    UserGroupMembership.create( user: @user, group: @super_group )
  end

  def find_indirect_membership
    UserGroupMembership.find_by( user: @user, group: @super_group )
  end

  def find_indirect_membership_with_deleted
    UserGroupMembership.find_all_by( user: @user, group: @super_group ).with_deleted_first
  end

  def create_memberships
    create_membership
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
      it "should raise an error, since only direct memberships can be destroyed" do
        expect { find_indirect_membership.destroy }.should raise_error RuntimeError
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
  end





  describe "#== ( other_membership ), i.e. euality relation, " do
    it "should return true if the two memberships represent the same membership" do
      membership = create_membership
      same_membership = find_membership
      membership.should == same_membership
    end
  end

  describe "after creation" do

    subject { @membership }

    before do
      @membership = create_membership
    end


    describe "#user" do
      its( :user ) { should == @user }
    end

    describe "#group" do
      its( :group ) { should == @group }
    end

  end

  describe "indirect membership" do

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

    it "should not be destroyable" do
      expect { @indirect_membership.destroy }.should raise_error RuntimeError
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

    describe "#direct_memberships" do
      it "should return the direct memberships corresponding to self, if self is an indirect membership" do
        @indirect_membership.direct_memberships.first.should == @membership
      end
      it "should return self, if self is a direct membership itself" do
        @membership.direct_memberships.first.should == @membership
      end
    end

    describe "#direct_memberships_now_and_in_the_past" do

      describe "of an indirect membership" do
        subject { @indirect_membership.direct_memberships_now_and_in_the_past }

        it "should return an ActiveRecord::Relation" do
          subject.kind_of?( ActiveRecord::Relation ).should be_true
        end
        it "should contain the direct membership" do
          subject.all.should include( @membership )
        end
      end

      describe "of a direct membership" do
        subject { @membership.direct_memberships_now_and_in_the_past }

        it "should include the direct membership" do
          subject.should include( @membership )
        end
      end

    end

  end

end
