require 'spec_helper'

unless ActiveRecord::Migration.table_exists? :my_structureables
  ActiveRecord::Migration.create_table :my_structureables do |t|
    t.string :name
  end
end

describe StructureableMixins::Roles do

  before do
    class MyStructureable < ActiveRecord::Base
      attr_accessible :name
      is_structureable( ancestor_class_names: %w(MyStructureable Group),
                        descendant_class_names: %w(MyStructureable Group User) )
    end

    @my_structureable = MyStructureable.create( name: "My Structureable" )
  end


  # Admins
  # ==========================================================================================

  describe "#admins_parent" do
    subject { @my_structureable.admins_parent }
    it { should == @my_structureable.find_admins_parent_group }
  end

  describe "#admins_parent!" do
    subject { @my_structureable.admins_parent! }
    describe "for the group not existing" do
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
    describe "for the group existing" do
      before { @admins_parent_group = @my_structureable.find_or_create_admins_parent_group }
      it { should == @admins_parent_group }
    end
  end

  describe "#find_admins_parent_group" do
    subject { @my_structureable.find_admins_parent_group }
    context "if existent" do
      before { @admins_parent_group = @my_structureable.find_or_create_admins_parent_group }
      it "should return the existant group" do
        subject.should == @admins_parent_group
      end
    end
    context "if absent" do
      it { should == nil }
    end
  end

  describe "#create_admins_parent_group" do
    subject { @my_structureable.create_admins_parent_group }
    context "if existant" do
      before { @my_structureable.create_admins_parent_group }
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
    context "if absent" do
      it "create the group" do
        @my_structureable.find_admins_parent_group.should == nil
        @admins_parent_group = subject
        @my_structureable.find_admins_parent_group.should == @admins_parent_group
      end
    end
  end

  describe "#admins" do
    subject { @my_structureable.admins }
    context "if the admins_parent_group exists" do
      before { @my_structureable.find_or_create_admins_parent_group }
      it { should == [] }
    end
    context "if admin users exist" do
      before do
        @admin_user = create( :user )
        @my_structureable.admins_parent.child_users << @admin_user
      end
      it "should return an array of admin users" do
        subject.should == [ @admin_user ]
      end
    end
    context "if the admins-parent group does not exist" do
      it "should return an empty array" do
        subject.should == []
      end
    end
  end

  describe "#admins_of_self_and_ancestors" do
    subject { @my_structureable.admins_of_self_and_ancestors }
    before do
      # ATTENTION: For cache deletion, the `descendants` method is called
      # on the ancestors.
      # Since the ancestor classes are not patched to include the
      # `MyStructureable` as descendants,
      # they are not included in the cache deletion process. To test cache
      # deletion properly,
      # we can't use `MyStructureable`. Therefore, we use a `Group` here
      # instead.
      #
      @my_structureable = create :group, name: "My Structureable"

      # @ancestor1 -> admin1
      #    |------- @ancestor2 -> admin2
      #    |            |------- @my_structureable -> my_admin
      #    |
      #    |------- @no_ancestor -> other_admin
      #
      @ancestor2 = @my_structureable.parent_groups.create name: 'Ancestor 2'
      @ancestor1 = @ancestor2.parent_groups.create name: 'Ancestor 1'
      @no_ancestor = @ancestor1.child_groups.create name: 'No Ancestor'

      @admin1 = create :user
      @admin2 = create :user
      @my_admin = create :user
      @other_admin = create :user

      @ancestor1.assign_admin @admin1
      @ancestor2.assign_admin @admin2
      @my_structureable.assign_admin @my_admin
      @no_ancestor.assign_admin @other_admin

      @my_structureable.reload
    end
    it "should include the ancestors' admins" do
      subject.should include @admin1
      subject.should include @admin2
    end
    it "should include the own direct admins" do
      subject.should include @my_admin
    end
    it "should not include admins that are neither direct admins nor ancestors' admins" do
      subject.should_not include @other_admin
    end
    describe "(caching)" do
      describe "after changing an ancestor's admins" do
        before do
          @my_structureable.admins_of_self_and_ancestors  # creates the cache
          @ancestor1.admins.destroy(@admin1)
          wait_for_cache
          @my_structureable.reload
        end
        it "should refresh the cached value" do
          subject.should_not include @admin1
          subject.should include @admin2, @my_admin
        end
        specify "the admin should still be in the database after calling destroy on the association" do
          User.find(@admin1.id).should be_present
        end
      end
    end
  end

  describe "#find_admins" do
    subject { @my_structureable.admins }
    context "if the admins_parent_group exists" do
      before { @my_structureable.create_admins_parent_group }
      it { should == [] }
    end
    context "if admin users exist" do
      before do
        @admin_user = create( :user )
        @my_structureable.admins_parent.child_users << @admin_user
      end
      it "should return an array of admin users" do
        subject.should == [ @admin_user ]
      end
    end
    context "if the admins-parent group does not exist" do
      it "should return an empty array" do
        subject.should == []
      end
    end
  end

  describe "#cached(:find_admins)" do
    before do
      @group = create(:group)
    end
    subject { @group.cached(:find_admins) }
    context "if the admins-parent group does not exist" do
      before do
        @group.cached(:find_admins)
      end
      it { should == @group.find_admins }
    end
    context "if the admins_parent_group exists" do
      before do
        @group.find_or_create_admins_parent_group
        @group.cached(:find_admins)
      end
      it { should == @group.find_admins }
    end
    context "if an admin users exists" do
      before do
        @group.find_or_create_admins_parent_group
        admin_user = create(:user)
        @group.admins_parent << admin_user
        @group.cached(:find_admins)
      end
      it { should == @group.find_admins }
    end
    context "if new admin is added via group" do
      before do
        @group.find_or_create_admins_parent_group
        admin_user = create(:user)
        @group.cached(:find_admins)
        wait_for_cache

        @group.admins_parent << admin_user
        @group.reload
      end
      it { should == @group.find_admins }
    end
    context "if new admin is added via child_users" do
      before do
        @group.find_or_create_admins_parent_group
        admin_user = create(:user)
        @group.cached(:find_admins)
        wait_for_cache

        @group.admins_parent.child_users << admin_user
        @group.reload
      end
      it { should == @group.find_admins }
    end
  end

  describe "#admins <<" do
    before { @admin_user = create( :user ) }
    subject { @my_structureable.assign_admin @admin_user }
    context "for the admin group existing" do
      before { @my_structureable.find_or_create_admins_parent_group }
      it "should add the user to the admins of the structureable object" do
        @my_structureable.admins.should_not include @admin_user
        subject
        @my_structureable.admins.should include @admin_user
      end
      it "should add the user to the group, not only the array" do
        subject
        @my_structureable.admins_parent.child_users.should include @admin_user
      end
    end
    context "for the admin group not existing" do
      it "should create it" do
        @my_structureable.find_admins_parent_group.should == nil
        subject
        @my_structureable.find_admins_parent_group.should be_kind_of Group
      end
      it "should add the user to the admins of the structureable object" do
        @my_structureable.find_admins_parent_group.should == nil
        subject
        @my_structureable.admins.should include @admin_user
      end
    end
  end

  # Main Admins
  # ==========================================================================================

  describe "#main_admins_parent" do
    subject { @my_structureable.main_admins_parent }
    it { should be_kind_of Group }
    it "should have the admins_parent as parent group" do
      @admins_parent = @my_structureable.admins_parent
      subject.parent_groups.should include @admins_parent
    end
    specify "users of this group should also be members of the admins_parent_group" do
      @user = create( :user )
      @my_structureable.main_admins_parent.child_users << @user
      @user.ancestor_groups.should include( @my_structureable.admins_parent,
                                            @my_structureable.main_admins_parent )
    end
  end

  describe "main_admins" do
    before { @admin_user = create( :user ) }
    subject { @my_structureable.main_admins }
    context "for the main_admins_parent_group existing" do
      before { @my_structureable.create_main_admins_parent_group }
      it "should not list users that are no admins" do
        @regular_user = create( :user )
        subject.should_not include @regular_user
      end
      it "should list main_admins added directly to the dag" do
        @my_structureable.main_admins_parent.should be_kind_of Group
        @my_structureable.main_admins_parent.child_users << @admin_user
        subject.should include @admin_user
      end
      it "should list main_admins added by 'assign_main_admin user'" do
        @my_structureable.assign_main_admin @admin_user
        subject.should include @admin_user
      end
      it "should not list the admins that are no main admins" do
        @my_structureable.assign_admin @admin_user
        subject.should_not include @admin_user
      end
    end
    context "for the main_admins_parent_group missing" do
      it "should still return an empty array" do
        subject.should == []
      end
    end
  end

  describe "#main_admins <<" do
    before { @admin_user = create( :user ) }
    subject { @my_structureable.assign_main_admin @admin_user }
    context "for the admin group existing" do
      before { @my_structureable.create_main_admins_parent_group }
      it "should add the user to the main admins of the structureable object" do
        @my_structureable.main_admins.should_not include @admin_user
        subject
        @my_structureable.main_admins.should include @admin_user
      end
    end
    context "for the admin group not existing" do
      it "should create the admin group and add the user to the main admins of the structureable object" do
        @my_structureable.main_admins.should == []
        subject
        @my_structureable.main_admins.should include @admin_user
      end
    end
  end


  # Structures
  # ==========================================================================================
  #
  #  my_structureable
  #         |----- officers_parent
  #                      |---------- admins_parent
  #                                     |------------ main_admins_parent
  #
  # Every admin is also an officer.
  # Every main_admin is also an admin and also an officer.
  #

  describe "structures: " do
    before { @user = create(:user) }
    specify "each admin should also be an officer" do
      @my_structureable.assign_admin @user
      @user.should be_in @my_structureable.admins
      @user.should be_in @my_structureable.officers
    end
    specify "each main_admin should also be an admin and also be an officer" do
      @my_structureable.assign_main_admin @user
      @user.should be_in @my_structureable.main_admins
      @user.should be_in @my_structureable.admins
      @user.should be_in @my_structureable.officers
    end
  end



  # Complex Structures
  # ------------------------------------------------------------------------------------------
  #
  #    group1
  #      |----- :officers_parent
  #      |         |--------------- :admins_parent
  #      |                               |---------- :main_admins_parent
  #      |----- group2
  #                |---- :officers_parent
  #                          |------------ :admins_parent
  #                                           |------------- :main_admins_parent
  #
  describe "complex structures: " do
    before do
      @group1 = create(:group)
      @group2 = create(:group); @group2.parent_groups << @group1
      @user = create(:user)
    end
    specify "an admin of group2 should not be considered an admin of group1" do
      @group1.admins.should == []
      @group2.assign_admin @user
      @group2.admins.should include @user
      @group1.admins.should == []
    end
    describe "for the sub group's officers_parent being created first" do
      before { @sub_group_officers_parent = @group2.create_officers_parent_group }
      specify "the parent group's officers_parent should not refer to the sub group's officers_parent" do
        @group2.find_officers_parent_group.should == @sub_group_officers_parent
        @group1.find_officers_parent_group.should_not == @sub_group_officers_parent
        @group1.find_officers_parent_group.should == nil
      end
    end
    describe "for the sub group's admins_parent beging created first" do
      before do
        @sub_group_admins_parent_group = @group2.find_or_create_admins_parent_group
        @sub_group_admins_parent_group.update_attributes( name: "group2.admins_parent" )
      end
      specify "the parent group's admins_parent should not refer to the sub group's admins_parent (Bug Fix!)" do
        @group2.find_admins_parent_group.should == @sub_group_admins_parent_group
        @group1.find_admins_parent_group.should_not == @sub_group_admins_parent_group
        @group1.find_admins_parent_group.should == nil
      end
    end
  end


  # Preventing Officers Cascades
  # ------------------------------------------------------------------------------------------
  #
  #    group1
  #      |----- :officers_parent
  #                |--------------- :admins_parent
  #                |                      |---------- :officers_parent  <---- forbidden
  #                |
  #                |----- :officers_parent   <------------------------------- forbidden
  #                |
  #                |----- :public_relations_officer
  #                                |
  #                                |----- :officers_parent    <-------------- forbidden
  #
  #
  describe "preventing officer cascades: " do
    before do
      @group1 = create :group
      @officers_parent = @group1.officers_parent
      @admins_parent = @group1.admins_parent
      @public_relations_officer = @officers_parent.child_groups.create
    end
    specify "it should not be possible to create an officers_parent under the admins parent" do
      @admins_parent.officers_parent.should == nil
      @admins_parent.create_officers_parent_group.should == nil
      @admins_parent.reload.children.should == []
    end
    specify "it should not be possible to create an offiers_parent under the officers_parent" do
      @officers_parent.officers_parent.should == nil
      @officers_parent.create_officers_parent_group.should == nil
      @officers_parent.reload.children.should == [@admins_parent, @public_relations_officer]
    end
    specify "it should not be possible to create an officers_parent under another officers group" do
      @public_relations_officer.officers_parent.should == nil
      @public_relations_officer.create_officers_parent_group.should == nil
      @public_relations_officer.reload.children.should == []
    end
    specify "calling #admins should not create forbidden officers_parent groups" do
      @admins_parent.admins
      @admins_parent.reload.children.should == []
      @officers_parent.admins
      @officers_parent.reload.children.should == [@admins_parent, @public_relations_officer]
      @public_relations_officer.admins
      @public_relations_officer.reload.children.should == []
    end
  end


  # Officers
  # ==========================================================================================

  describe "officers_parent_group" do
    before do
      # @container_group
      #     |------------------ @officers_parent ---- @officer1
      #     |------------------ @container_subgroup
      #                              |--------------- @subgroup_officers_parent
      #                                                  |--- @officer2
      #
      @container_group = create( :group )
      @container_subgroup = create( :group ) # this is to test if subgroup's officers are listed as well
      @container_subgroup.parent_groups << @container_group
      @officers_parent = @container_group.create_officers_parent_group
      @subgroup_officers_parent = @container_subgroup.create_officers_parent_group
      @officer1 = @container_group.create_officer_group
      @officer2 = @container_subgroup.create_officer_group
      @officer1_user = create( :user ); @officer1.child_users << @officer1_user
      @officer2_user = create( :user ); @officer2.child_users << @officer2_user
      @container_group.reload
      @container_subgroup.reload
      @officers_parent.reload
      @subgroup_officers_parent.reload
    end

    describe "#create_officers_parent_group" do
      it "should create the officers_parent_group" do
        @officers_parent.has_flag?( :officers_parent ).should be_true
        @officers_parent.parent_groups.should include( @container_group )
      end
    end

    describe "#find_officers_parent_group" do
      subject { @container_group.find_officers_parent_group }
      it "should find the officers_parent_group" do
        subject.should == @officers_parent
        subject.has_flag?( :officers_parent ).should be_true
      end
    end

    describe "#find_officers_groups" do
      subject { @container_group.find_officers_groups }
      it "should find the officers of the container group" do
        subject.should include( @officer1 )
      end
      it "should not find the officers of the container group's subgroups" do
        subject.should_not include( @officer2 )
      end
    end

    subject { @container_group }
    its( :officers_parent ) { should == @officers_parent }
    its( :officers_parent! ) { should == @officers_parent }

    describe "#officers" do
      subject { @container_group.officers }
      it "should list the users that are officers" do
        subject.should include @officer1_user
      end
      it "should also list the officers of the sub-groups of this group" do
        subject.should include @officer2_user
      end
    end

  end

end
