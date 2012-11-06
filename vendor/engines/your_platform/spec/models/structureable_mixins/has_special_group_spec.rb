require 'spec_helper'

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

      has_special_group :global_admins_parent, global: true
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

  describe "#testers_parent!" do
    subject { @my_structureable.testers_parent! }
    it { should == @my_structureable.find_or_create_testers_parent_group }
  end

  describe "#testers_parent" do
    subject { @my_structureable.testers_parent }
    it { should == @my_structureable.find_testers_parent_group }
  end

  describe "#testers" do
    subject { @my_structureable.testers }
    context "for the testers_parent group having a user" do
      before { @my_structureable.testers_parent!.child_users << @tester_user }
      it "should return an array including this user" do
        subject.should == [ @tester_user ]
      end
    end
    context "for the testers_parent group being absent" do
      it "should be nil" do
        subject.should == nil
      end
    end
    context "for the testers_parent group being existent but having no users" do
      before { @my_structureable.create_testers_parent_group }
      it "should return an empty array" do
        subject.should == []
      end
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
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
  end
  
  context "(global special_groups)" do
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
      context "if existent" do
        before { @global_admins_parent_group = MyStructureable.create_global_admins_parent_group }
        it { should == @global_admins_parent_group }
      end
      context "if absent" do
        it { should == nil }
      end
    end
    describe ".global_admins_parent!" do
      subject { MyStructureable.global_admins_parent! }
      it { should be_kind_of( Group ) }
    end
  end

end
