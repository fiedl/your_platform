require 'spec_helper'

unless ActiveRecord::Migration.table_exists? :my_structureables
  ActiveRecord::Migration.create_table :my_structureables do |t|
    t.string :name
  end
end

describe StructureableMixins::HasSpecialGroups do

  before do
    class MyStructureable < ActiveRecord::Base
      attr_accessible :name
      is_structureable( ancestor_class_names: %w(MyStructureable),
                        descendant_class_names: %w(MyStructureable Group User) )
    end

    @my_structureable = MyStructureable.create( name: "My Structureable" )
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
      specify "..." do
        pending "it is not clear how this should behvave, yet, since we had no use case for that so far."
      end
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



end
