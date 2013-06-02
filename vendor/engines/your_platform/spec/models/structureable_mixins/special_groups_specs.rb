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
  end

  describe "#find_or_create_special_group" do
  end


  # Global Special Groups
  # i.e. independent, e.g. the everyone group: `Group.everyone`
  # ==========================================================================================

  describe ".find_special_group" do
  end

  describe ".create_special_group" do
  end

  describe ".find_or_create_special_group" do
  end



end
