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
      is_structureable( ancestor_class_names: %w(MyStructureable),
                        descendant_class_names: %w(MyStructureable Group User) )
    end

    @my_structureable = MyStructureable.create( name: "My Structureable" )
  end

  describe "#admins_parent" do
    subject { @my_structureable.admins_parent }
    it { should == @my_structureable.find_admins_parent_group }
  end

  describe "#admins_parent!" do
    subject { @my_structureable.admins_parent! }
    it { should be_kind_of Group }
  end

  describe "#find_admins_parent_group" do
    subject { @my_structureable.find_admins_parent_group }
    context "if existent" do
      before { @admins_parent_group = @my_structureable.create_admins_parent_group }
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
      before { @my_structureable.create_admins_parent_group } 
      it { should == [] }
    end
    context "if admin users exist" do
      before do 
        @admin_user = create( :user )
        @my_structureable.admins_parent!.child_users << @admin_user
      end
      it "should return an array of admin users" do
        subject.should == [ @admin_user ]
      end
    end
    context "if the admins-parent group does not exist" do
      it "should return nil" do
        subject.should == nil
      end
    end
  end

end
