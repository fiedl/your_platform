require 'spec_helper'

describe UserGroupMembership do

  before do
    @group = Group.create( name: "Group 1" )
    @super_group = Group.create( name: "Parent Group of Groups 1 and 2" )
    @other_group = Group.create( name: "Group 2" )
    @group.parent_groups << @super_group
    @other_group.parent_groups << @super_group
    @other_user = create(:user)
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

  def find_membership_now_and_in_the_past
    UserGroupMembership.find_all_by( user: @user, group: @group ).now_and_in_the_past.first
  end

  def find_indirect_membership
    UserGroupMembership.find_by( user: @user, group: @super_group )
  end

  def find_indirect_membership_now_and_in_the_past
    UserGroupMembership.find_all_by( user: @user, group: @super_group ).now_and_in_the_past.first
  end

  def create_other_membership
    UserGroupMembership.create( user: @user, group: @other_group )
  end
  
  def create_another_membership
    UserGroupMembership.create( user: @other_user, group: @group )
  end
  
  def find_other_membership
    UserGroupMembership.find_by( user: @user, group: @other_group )
  end

  def find_other_membership_now_and_in_the_past
    UserGroupMembership.find_all_by( user: @user, group: @other_group).now_and_in_the_past.first
  end

  def create_memberships
    create_membership
    create_other_membership
    create_another_membership
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
      expect { UserGroupMembership.create( user: @user ) }.to raise_error RuntimeError
      expect { UserGroupMembership.create( group: @group ) }.to raise_error RuntimeError
    end
    it "should be able to identify a user by its 'user_title'" do
      UserGroupMembership.create( user_title: @user.title, group_id: @group.id )
      @user.parents.should include @group
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
      it "should not find memberships that are invalid at the present time" do
        find_membership.update_attribute(:valid_to, 1.hour.ago)
        UserGroupMembership.find_all_by( user: @user )
          .should_not include( find_membership_now_and_in_the_past )
        UserGroupMembership.find_all_by( user: @user )
          .should include find_other_membership
      end
      it "should be able to identify users by 'user_title'" do
        UserGroupMembership.find_all_by( user_title: @user.title ).each do |membership|
          membership.user_id.should == @user.id
        end
      end
    end
    describe ".find_all_by.now_and_in_the_past" do
      before { find_membership.make_invalid }
      it "should find all memberships, including the ones that are invalid at the present time" do
        UserGroupMembership.find_all_by( user: @user ).now_and_in_the_past
          .should include( find_membership_now_and_in_the_past, find_indirect_membership, find_other_membership )
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

<<<<<<< HEAD
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
          expect { find_membership.delete! }.to raise_error RuntimeError
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

=======
>>>>>>> 842d07722b30e050a4464cf205a930f64bc556d0
  describe "#== ( other_membership ), i.e. euality relation, " do
    it "should return true if the two objects represent the same membership" do
      membership = create_membership
      same_membership = find_membership
      membership.should == same_membership
    end
  end


  # Access Methods to Associated User and Group
  # ====================================================================================================

  describe "Access Method to Assiciation" do
    before { @membership = create_membership }
    subject { @membership }

    describe "#user" do
      its(:user) { should == @user }
    end
    describe "#user=" do
      subject { @membership.user = @other_user }
      it "should assign a user to the membership" do
        @membership.user.should == @user
        subject
        @membership.user.should == @other_user
      end
    end
    describe "#user_id" do
      subject { @membership.user_id }
      it { should == @user.id }
    end
    describe "#user_title" do
      subject { @membership.user_title }
      it { should == @user.title }
    end
    describe "#user_title=" do
      subject { @membership.user_title = @other_user.title }
      it "should assign the user matching the title to the membership" do
        @membership.user.should == @user
        subject
        @membership.user.should == @other_user
      end
    end
    describe "#group" do
      its(:group) { should == @group }
    end
    describe "#group_id" do
      subject { @membership.group_id }
      it { should == @group.id }
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
    # it "should be the same as #direct_memberships.now_and_in_the_past" do
    #   find_indirect_membership.direct_memberships_now_and_in_the_past.should ==
    #     find_indirect_membership.direct_memberships.now_and_in_the_past
    # end
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
  

  # Access Methods to Associated Indirect Memberships
  # ====================================================================================================  
  
  describe "#indirect_memberships" do
    before do
      @membership = UserGroupMembership.create(user: @user, group: @group)
      @indirect_membership = find_indirect_membership
    end
    subject { @membership.indirect_memberships }
    it { should include find_indirect_membership }
    it { should_not include find_membership }
    describe "for invalidated memberships" do
      before do 
        @membership.update_attribute(:valid_from, 2.hours.ago)
        @membership.update_attribute(:valid_to, 1.hour.ago)
      end
      it "should still find the indirect memberships" do
        subject.should include @indirect_membership
      end
    end
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

    it "should have the same validity range (valid_from) as the direct membership" do
      @indirect_membership.valid_from.should == @membership.valid_from
    end

    it "should have the same validity range (valid_to) as the direct membership" do
      @indirect_membership.valid_to.should == @membership.valid_to
    end

    it "should also effect the direct membership on change of the valid_from date" do
      new_time = 1.hour.ago
      @membership.valid_from = new_time
      @membership.save
      @indirect_membership.valid_from.to_i.should == new_time.to_i
    end

    it "should also effect the direct membership on change of the valid_to date" do
      new_time = Time.current + 1.hour
      @membership.invalidate
      @membership.valid_to = new_time
      @membership.save
      @indirect_membership.reload
      @indirect_membership.valid_to.to_i.should == new_time.to_i
    end

    it "should be effected by the direct membership on change of the valid_from date" do
      new_time = 1.hour.ago
      @indirect_membership.valid_from = new_time
      @indirect_membership.save
      @membership.reload
      @membership.valid_from.to_i.should == new_time.to_i
    end

    it "should be effected by the direct membership on change of the valid_to date" do
      new_time = Time.current + 1.hour
      @membership.invalidate # need to archive the *direct* membership, ...
      @indirect_membership.reload
      @indirect_membership.valid_to = new_time # but can change the time of the *indirect*.
      @indirect_membership.save
      @membership.reload
      @membership.valid_to.to_i.should == new_time.to_i
    end
  end

  # Methods to Change the Membership
  # ====================================================================================================       

  describe "#move_to_group( group )" do
    before do
      create_membership
      find_membership.move_to_group( @other_group )
      sleep 1.1 # just to make sure the time comparison works
    end
    it "should hide old direct membership" do
      find_membership.should == nil
    end
    it "should create a new membership between the user and the given group" do
      find_other_membership.should_not == nil
    end
  end
  
end
