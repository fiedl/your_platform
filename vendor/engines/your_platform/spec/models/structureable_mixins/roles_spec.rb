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

  describe "#admins <<" do
    before { @admin_user = create( :user ) }
    subject { @my_structureable.admins << @admin_user }
    context "for the admin group existing" do
      before { @my_structureable.create_admins_parent_group }
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
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
  end

  describe "#admins!" do
    subject { @my_structureable.admins! }
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
      it "should return an array as well" do
        subject.should == []
      end
      it "should create the special group" do
        @my_structureable.admins_parent.should == nil
        subject
        @my_structureable.admins_parent.should be_kind_of Group
      end
    end
  end

  describe "#admins! <<" do
    before { @admin_user = create( :user ) }
    subject { @my_structureable.admins! << @admin_user }
    context "for the admin group existing" do
      before { @my_structureable.create_admins_parent_group }
      it "should add the user to the admins of the structureable object" do
        @my_structureable.admins.should_not include @admin_user
        subject
        @my_structureable.admins.should include @admin_user
      end
    end
    context "for the admin group not existing" do
      it "should create the admins_parent_group" do
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

  describe "#main_admins_parent!" do
    subject { @my_structureable.main_admins_parent! }
    it { should be_kind_of Group }
    it "should have the admins_parent as parent group" do
      @admins_parent = @my_structureable.admins_parent!
      subject.parent_groups.should include @admins_parent 
    end
    specify "users of this group should also be members of the admins_parent_group" do
      @user = create( :user )
      @my_structureable.main_admins_parent!.child_users << @user 
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
      it "should list main_admins added by 'main_admins << user'" do
        @my_structureable.main_admins << @admin_user
        subject.should include @admin_user
      end
      it "should not list the admins that are no main admins" do
        @my_structureable.admins << @admin_user
        subject.should_not include @admin_user
      end
    end
    context "for the main_admins_parent_group missing" do
      it { should == nil }
    end
  end

  describe "#main_admins <<" do
    before { @admin_user = create( :user ) }
    subject { @my_structureable.main_admins << @admin_user }
    context "for the admin group existing" do
      before { @my_structureable.create_main_admins_parent_group }
      it "should add the user to the main admins of the structureable object" do
        @my_structureable.main_admins.should_not include @admin_user
        subject
        @my_structureable.main_admins.should include @admin_user
      end
    end
    context "for the admin group not existing" do
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
  end

  describe "#main_admins! <<" do
    before { @admin_user = create( :user ) }
    subject { @my_structureable.main_admins! << @admin_user }
    context "for the admin group existing" do
      before { @my_structureable.create_main_admins_parent_group }
      it "should add the user to the main admins of the structureable object" do
        @my_structureable.main_admins.should_not include @admin_user
        subject
        @my_structureable.main_admins.should include @admin_user
      end
    end
    context "for the admin group not existing" do
      it "should create the special group and add the user to the main admins of the structureable object" do
        @my_structureable.main_admins_parent.should == nil
        subject
        @my_structureable.main_admins.should include @admin_user
      end
    end
  end

end
