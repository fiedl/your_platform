require 'spec_helper'

#if ActiveRecord::Migration.table_exists? :my_structureables
#  ActiveRecord::Migration.drop_table :my_structureables
#end

unless ActiveRecord::Migration.table_exists? :my_structureables
  ActiveRecord::Migration.create_table :my_structureables do |t|
    t.string :name
  end
end


describe StructureableMixins::HasSpecialGroup do

  before do

    class MyStructureable < ActiveRecord::Base
      attr_accessible :name
      is_structureable( ancestor_class_names: %w(MyStructureable),
                        descendant_class_names: %w(MyStructureable Group User) )
      has_special_group :testers_parent # <--!!! this determines the method names in the tests below.
      has_special_group :main_testers_parent, :child_of => :testers_parent
      has_special_group :vip_testers_parent, :child_of => :main_testers_parent
    end

    @my_structureable = MyStructureable.create( name: "My Structureable Object" )

  end

  subject { @my_structureable }

  it { should respond_to( :find_testers_parent_group ) }

  describe "#find_special_group" do
    subject { @my_structureable.find_special_group( :testers_parent ) }
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

  describe "#create_special_group" do
    context "if not existent" do
      it "should create the special group" do
        @my_structureable.find_special_group( :testers_parent ).should == nil
        new_special_group = @my_structureable.create_special_group( :testers_parent )
        @my_structureable.find_special_group( :testers_parent ).should == new_special_group
      end
    end
    context "if existent" do
      before do
        @my_structureable.create_special_group( :testers_parent )
      end
      it "should raise an error" do
        expect { @my_structureable.create_special_group( :testers_parent ) }.to raise_error
      end
    end
    context "if the :child_of option is specified" do
      it "should create the new special_group as child of the given group" do
        new_special_group = @my_structureable.create_special_group( :main_testers_parent,
                                                                    :child_of => :testers_parent )
        new_special_group.parent_groups.first.should == @my_structureable.find_special_group( :testers_parent )
      end
    end
    context "if the :child_of option is not specified" do
      it "should create the new special_group as child of the structureable object itself" do
        new_special_group = @my_structureable.create_special_group( :testers_parent )
        @my_structureable.children.should include( new_special_group )
      end
    end
    context "for deeper structures" do
      it "should create all ancestor special_groups on the way" do
        new_special_group = @my_structureable.create_special_group( :vip_testers_parent )
        @testers_parent = @my_structureable.child_groups.find_by_flag( :testers_parent )
        @testers_parent.should_not == nil
        @main_testers_parent = @testers_parent.child_groups.find_by_flag( :main_testers_parent )
        @main_testers_parent.should_not == nil
        @main_testers_parent.child_groups.should include( new_special_group )
      end
    end
  end

  describe "#find_or_create_special_group_parent_for" do
    context "for a given :child_of parameter" do
      it "should create the special_group given by the :child_for parameter" do
        @my_structureable.find_or_create_special_group_parent_for( :heroes_parent, :child_of => :superheroes_parent )
        @my_structureable.find_special_group( :superheroes_parent ).should_not be_nil
      end
    end
    context "for a missing :child_of parameter" do
      context "if the :child_for parameter is specified during #has_special_group" do
        it "should create the special_group given by the :child_for parameter specified there" do
          @my_structureable.find_or_create_special_group_parent_for( :main_testers_parent )
          @my_structureable.find_special_group( :testers_parent ).should_not be_nil
        end
      end
      context "if the :child_for parameter is not specified anywhere" do
        it "should return the structureable object itself as parent" do
          @my_structureable.find_or_create_special_group_parent_for( :foo_parents ).should == @my_structureable
        end
      end
    end
  end

  describe "#find_testers_parent_group" do
    before do
      @testers_parent = @my_structureable.child_groups.create
      @testers_parent.add_flag( :testers_parent )
    end
    subject { @my_structureable.find_testers_parent_group }
    it "should be the same as 'find_special_group( :testers_parent )'" do
      subject.should == @my_structureable.find_special_group( :testers_parent )
    end
  end
  


end
