require 'spec_helper'

unless ActiveRecord::Migration.table_exists? :my_structureables
  ActiveRecord::Migration.create_table :my_structureables do |t|
    t.string :name
  end
end

describe StructureableMixins::HasSpecialGroups do

  before do
    class MyStructureable < ActiveRecord::Base
      is_structureable( ancestor_class_names: %w(MyStructureable),
                        descendant_class_names: %w(MyStructureable Group User) )
    end

    @my_structureable = MyStructureable.create( name: "My Structureable" )

    def title
      name
    end
  end


  # Local Special Groups
  # i.e. descendants of structureables, e.g. officers groups: `group_xy.officers_parent`
  # ==========================================================================================

  describe "#find_special_group" do
    subject { @my_structureable.find_special_group( :my_special_group ) }
    describe "for the group existing" do
      before { @my_special_group = @my_structureable.create_special_group( :my_special_group ) }
      it { should == @my_special_group }
    end
    describe "for the group not existing" do
      it { should == nil }
    end
  end

  describe "#create_special_group" do
    subject { @my_structureable.create_special_group( :my_special_group ) }
    describe "for the group existing" do
      before { @my_special_group = @my_structureable.create_special_group( :my_special_group ) }
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
    describe "for the group not existing" do
      it "should create the group" do
        @my_structureable.find_special_group(:my_special_group).should == nil
        subject
        @my_structureable.find_special_group(:my_special_group).should be_kind_of Group
      end
    end
  end

  describe "#find_or_create_special_group" do
    subject { @my_structureable.find_or_create_special_group( :my_special_group ) }
    describe "for the group existing" do
      before { @my_special_group = @my_structureable.create_special_group( :my_special_group ) }
      it "should find the group" do
        subject.should == @my_special_group
      end
    end
    describe "for the group not existing" do
      it "should create the group" do
        @my_structureable.find_special_group(:my_special_group).should == nil
        subject
        @my_structureable.find_special_group(:my_special_group).should be_kind_of Group
      end
    end
  end


  # Structures
  # ------------------------------------------------------------------------------------------
  #
  #   my_structureable
  #          |----------- my_special_parent_group
  #                             |------------- my_special_group
  #

  describe "structures: " do
    describe "#find_or_create_special_group(..., parent_element)" do
      subject do
        @my_structureable
          .find_or_create_special_group(:my_special_group,
                                        parent_element: @my_structureable.find_or_create_special_group(:my_special_parent_group)
                                        )
      end
      it "should create the special group" do
        @my_structureable.find_special_group(:my_special_group).should == nil
        subject
        @my_structureable.find_special_group(:my_special_group).should == nil
        @my_structureable.find_special_group(:my_special_group,
                                             parent_element: @my_structureable.find_special_group(:my_special_parent_group)
                                             ).should be_kind_of Group
      end
      it "should create the special parent group as well" do
        @my_structureable.find_special_group(:my_special_parent_group).should == nil
        subject
        @my_structureable.find_special_group(:my_special_parent_group).should be_kind_of Group
      end
    end
  end


  # Complex Structures
  # ------------------------------------------------------------------------------------------
  #
  # Consider group structures like this:
  #
  #    group1
  #      |----- :admins_parent [1]
  #      |               |------- :main_admins_parent
  #      |
  #      |----- group2
  #               |------ :admins_parent [2]
  #                                |----- :main_admins_parent
  #
  #
  # Asking `group1.find_special_group(:admins_parent)` should always refer to [1],
  # never to [2]. Particularly, it should not refer to [2] if [1] does not exist.
  #
  # But `group1.find_special_group(:main_admins_parent) should also work, i.e. one
  # can't simply consider the child groups.
  #
  # Since the admins_parent and the main_admins_parent are defined in
  # StructureableMixins::Roles, this scenario is tested there, more extensively.
  #
  describe "complex structures: " do
    before do
      @group1 = create(:group)
      @group2 = create(:group); @group2.parent_groups << @group1
    end
    describe "@group1#find_special_group" do
      subject { @group1.find_special_group(:admins_parent) }
      describe "for no admins_parent existing down the tree at all" do
        it { should == nil }
      end
      describe "for an admins_parent existing under @group1" do
        before { @admins_parent_1 = @group1.create_special_group(:admins_parent) }
        it { should == @admins_parent_1 }
      end
      describe "for an admins_parent existing under @group1 and under @group2" do
        before do
          @admins_parent_1 = @group1.create_special_group(:admins_parent)
          @admins_parent_2 = @group2.create_special_group(:admins_parent)
        end
        it "should return the own admins_parent, i.e. @admins_parent_1." do
          subject.should == @admins_parent_1
        end
      end
      describe "for an admins_parent existing under @group2, but not under @group1" do
        before { @admins_parent_2 = @group2.create_special_group(:admins_parent) }
        it "should return nil rather than the admins_parent of @group2" do
          subject.should_not == @admins_parent_2
          subject.should == nil
        end
      end
    end
  end


  # Global Special Groups
  # i.e. independent, e.g. the everyone group: `Group.everyone`
  # ==========================================================================================

  describe ".find_special_group" do
    subject { MyStructureable.find_special_group( :my_special_group ) }
    describe "for the special group existing" do
      before { @my_special_group = MyStructureable.create_special_group(:my_special_group) }
      it "should find the group" do
        subject.should == @my_special_group
      end
    end
    describe "for the special group not existing" do
      it { should == nil }
    end
    describe "for the special group existing locally rather than globally" do
      before do
        @my_structureable = MyStructureable.new
        @my_structureable.create_special_group(:my_special_group)
      end
      pending "it is not clear how this should behvave, yet, since we had no use case for that so far."
    end
  end

  describe ".create_special_group" do
    subject { MyStructureable.create_special_group( :my_special_group ) }
    it "should create the global special group" do
      MyStructureable.find_special_group(:my_special_group).should == nil
      subject
      MyStructureable.find_special_group(:my_special_group).should be_kind_of Group
    end
  end

  describe ".find_or_create_special_group" do
    subject { MyStructureable.find_or_create_special_group( :my_special_group ) }
    describe "for the special group not existing" do
      it "should create the global special group" do
        MyStructureable.find_special_group(:my_special_group).should == nil
        subject
        MyStructureable.find_special_group(:my_special_group).should be_kind_of Group
      end
    end
  end


  # Use Case: Testers
  # ==========================================================================================

  describe "Use Case 'Testers': " do

    before do

      class MyStructureable < ActiveRecord::Base
        is_structureable( ancestor_class_names: %w(MyStructureable),
                          descendant_class_names: %w(MyStructureable Group User) )

        def find_testers_parent_group
          find_special_group(:testers_parent)
        end

        def create_testers_parent_group
          create_special_group(:testers_parent)
        end

        def find_or_create_testers_parent_group
          find_or_create_special_group(:testers_parent)
        end

        def testers_parent
          find_or_create_testers_parent_group
        end

        def testers_parent!
          find_testers_parent_group || raise('special group :testers_parent does not exist.')
        end

        def testers
          find_or_create_testers_parent_group.descendant_users
        end

        def find_main_testers_parent_group
          find_special_group(:main_testers_parent, parent_element: find_testers_parent_group )
        end

        def create_main_testers_parent_group
          create_special_group(:main_testers_parent, parent_element: find_or_create_testers_parent_group )
        end

        def find_or_create_main_testers_parent_group
          find_or_create_special_group(:main_testers_parent, parent_element: find_or_create_testers_parent_group )
        end

        def main_testers_parent
          find_or_create_main_testers_parent_group
        end

        def main_testers_parent!
          find_main_testers_parent_group || raise('special group :main_testers_parent does not exist.')
        end

        def main_testers
          main_testers_parent.descendant_users
        end

        def find_vip_testers_parent_group
          find_special_group(:vip_testers_parent, parent_element: find_main_testers_parent_group )
        end

        def create_vip_testers_parent_group
          create_special_group(:vip_testers_parent, parent_element: find_or_create_main_testers_parent_group )
        end

        def find_or_create_vip_testers_parent_group
          find_or_create_special_group(:vip_testers_parent, parent_element: find_or_create_main_testers_parent_group )
        end

        def vip_testers_parent
          find_or_create_vip_testers_parent_group
        end

        def vip_testers_parent!
          find_vip_testers_parent_group || raise('special group :vip_testers_parent does not exist.')
        end

        def vip_testers
          vip_testers_parent.descendant_users
        end

      end

      @my_structureable = MyStructureable.create( name: "My Structureable Object" )
      @tester_user = create( :user )

    end

    subject { @my_structureable }

    it { should respond_to( :find_testers_parent_group ) }

    describe "#find_testers_parent_group" do
      subject { @my_structureable.find_testers_parent_group }
      context "if not existent" do
        it { should be_nil }
      end
      context "if existent" do
        before do
          @testers_parent = @my_structureable.child_groups.create
          @testers_parent.add_flag( :testers_parent )
        end
        it "should return the matching group" do
          subject.should == @testers_parent
        end
      end
    end

    describe "#create_testers_parent_group" do
      subject { @my_structureable.create_testers_parent_group }
      context "if not existent" do
        it "should create the special group" do
          @my_structureable.find_testers_parent_group.should == nil
          new_special_group = subject
          new_special_group.should be_kind_of( Group )
          @my_structureable.find_testers_parent_group.should == new_special_group
        end
      end
      context "if existent" do
        before do
          @my_structureable.create_testers_parent_group
        end
        it "should raise an error" do
          expect { subject }.to raise_error
        end
      end
      context "if the :child_of option is not specified" do
        subject { @my_structureable.create_testers_parent_group }
        it "should create the new special_group as child of the structureable object itself" do
          new_special_group = subject
          new_special_group.should be_kind_of( Group )
          @my_structureable.children.should include( new_special_group )
        end
      end
      context "if the :child_of option is specified" do
        subject { @my_structureable.create_main_testers_parent_group } # :child_of has been set to :testers_parent
        it "should create the new special_group as child of the given group" do
          new_special_group = subject
          new_special_group.should be_kind_of( Group )
          new_special_group.parent_groups.first.should == @my_structureable.find_testers_parent_group
        end
      end
      context "for deeper structures" do
        subject { @my_structureable.create_vip_testers_parent_group }
        it "should create all ancestor special_groups on the way" do
          new_special_group = subject
          new_special_group.should be_kind_of( Group )
          @testers_parent = @my_structureable.child_groups.find_by_flag( :testers_parent )
          @testers_parent.should_not == nil
          @main_testers_parent = @testers_parent.child_groups.find_by_flag( :main_testers_parent )
          @main_testers_parent.should_not == nil
          @main_testers_parent.child_groups.should include( new_special_group )
        end
      end
    end

    describe "#find_or_create_testers_parent_group" do
      subject { @my_structureable.find_or_create_testers_parent_group }
      context "for an existing special group" do
        before { @my_structureable.create_testers_parent_group }
        it { should == @my_structureable.find_testers_parent_group }
      end
      context "for an absent special group" do
        it "should create the group" do
          @my_structureable.find_testers_parent_group.should == nil
          subject
          @my_structureable.find_testers_parent_group.should be_kind_of( Group )
        end
      end
    end

    describe "#testers_parent" do
      subject { @my_structureable.testers_parent }
      it { should == @my_structureable.find_or_create_testers_parent_group }
    end

    describe "#testers" do
      subject { @my_structureable.testers }
      context "for an existing special group" do
        before { @my_structureable.create_testers_parent_group }
        it { should == @my_structureable.testers }
      end
      context "for an absent special group" do
        its(:to_a) { should be_kind_of Array }
        it { should_not == nil }
      end
    end

    describe "#testers <<" do
      subject { @my_structureable.testers << @tester_user }
      context "for an existing special group" do
        before { @my_structureable.create_testers_parent_group }
        it "should add the user" do
          @my_structureable.find_testers_parent_group.child_users.should == []
          subject
          @my_structureable.find_testers_parent_group.child_users.should == [ @tester_user ]
        end
      end
      context "for a non-existing special group" do
        it "should create the special group" do
          @my_structureable.find_testers_parent_group.should == nil
          subject
          @my_structureable.find_testers_parent_group.should be_kind_of Group
        end
        it "should add the user" do
          @my_structureable.find_testers_parent_group.should == nil
          subject
          @my_structureable.find_testers_parent_group.child_users.should == [ @tester_user ]
        end
      end
    end

  end


  # Use Case: Global Admins
  # ==========================================================================================

  describe "Use Case 'Global Admins': " do

    before do
      class MyStructureable < ActiveRecord::Base
        is_structureable( ancestor_class_names: %w(MyStructureable),
                          descendant_class_names: %w(MyStructureable Group User) )

        def self.find_global_admins_parent_group
          find_special_group(:global_admins_parent)
        end

        def self.create_global_admins_parent_group
          create_special_group(:global_admins_parent)
        end

        def self.find_or_create_global_admins_parent_group
          find_or_create_special_group(:global_admins_parent)
        end

        def self.global_admins_parent
          find_or_create_global_admins_parent_group
        end

        def self.global_admins_parent!
          find_global_admins_parent_group || raise('special group :global_admins_parent does not exist.')
        end

        def self.global_admins
          find_or_create_global_admins_parent_group.descendant_users
        end
      end
    end

    describe ".find_global_admins_parent_group" do
      subject { MyStructureable.find_global_admins_parent_group }
      context "if existent" do
        before { @global_admins_parent_group = MyStructureable.create_global_admins_parent_group }
        it { should == @global_admins_parent_group }
      end
      context "if absent" do
        it { should == nil }
      end
    end
    describe ".global_admins_parent" do
      subject { MyStructureable.global_admins_parent }
      it { should be_kind_of( Group ) }
    end

  end

end
