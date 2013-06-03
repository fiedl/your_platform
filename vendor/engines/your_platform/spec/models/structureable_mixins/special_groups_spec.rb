require 'spec_helper'

unless ActiveRecord::Migration.table_exists? :my_structureables
  ActiveRecord::Migration.create_table :my_structureables do |t|
    t.string :name
  end
end

describe StructureableMixins::SpecialGroups do

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
  # StructureableMixins::Roles, this scenario is tested there.
  

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
      pending "it is not clear how this should behvave, yet."
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
