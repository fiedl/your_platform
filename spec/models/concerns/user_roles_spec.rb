require 'spec_helper'

describe User do

  before do
    @user = create( :user )
    @user.save
  end


  # Roles
  # ==========================================================================================

  describe "#role_for" do
    context "for pages" do
      before do
        @object = create( :page )
        @object.create_main_admins_parent_group
        @sub_object = create( :group ); @sub_object.parent_pages << @object
        @sub_sub_object = create( :user ); @sub_sub_object.parent_groups << @sub_object
      end
      subject { @user.role_for @object }

      context "for the user being not related to the object" do
        it { should == nil }
      end
      context "for the user being an admin of the object" do
        before { @object.admins << @user }
        it { should == :admin }
      end
      context "for the user being a main_admin of the object" do
        before { @object.main_admins << @user }
        it { should == :main_admin }
      end
      context "for the object being not structureable" do
        before { @object = "This is a string." }
        it { should == nil }
      end
      context "for descendant objects of administrated objects" do
        before { @object.admins << @user }
        it "should return the inherited role" do
          @user.role_for( @object ).should == :admin
          @user.role_for( @sub_object ).should == :admin
          @user.role_for( @sub_sub_object ).should == :admin
        end
      end
    end
    context "for groups" do
      before do
        @object = create(:group)
      end
      subject { @user.role_for @object }

      context "for the user being a member of the object" do
        before { @object << @user }
        it { should == :member }
      end
    end
  end

  # Admins
  # ------------------------------------------------------------------------------------------

  describe "#admin_of" do
    before do
      @group = create( :group, name: "Directly Administrated Group" )
      @group.find_or_create_admins_parent_group
      @group.admins_parent.child_users << @user
    end
    subject { @user.admin_of }
    it { should == @user.administrated_objects }
  end

  describe "#admin_of?" do
    before do
      @group = create( :group, name: "Directly Administrated Group" )
      @sub_group = create( :group, name: "Indirectly Administrated Group" )
      @sub_group.parent_groups << @group
    end
    context "for the user being admin" do
      before do
        @group.find_or_create_admins_parent_group
        @group.admins_parent.child_users << @user  # the @user is direct admin of @group
      end
      context "for directly administrated objects" do
        subject { @user.admin_of? @group }
        it "should state that the user is admin" do
          subject.should == true
        end
      end
      context "for indirectly administrated objects" do
        subject { @user.admin_of? @sub_group }
        it "should state that the user is admin" do
          subject.should == true
        end
      end
    end
    context "for the user being main admin" do
      before do
        @group.create_main_admins_parent_group
        @group.main_admins_parent.child_users << @user
      end
      subject { @user.admin_of? @group }
      it { should == true }
    end
    context "for some object the user is no admin of" do
      before { @other_object = Page.create }
      subject { @user.admin_of? @other_object }
      it { should == false }
    end
  end

  describe "#directly_administrated_objects" do
    before do
      @group = create( :group, name: "Directly Administrated Group" )
      @group.find_or_create_admins_parent_group
    end
    subject { @user.directly_administrated_objects }
    it { should be_kind_of Array }
    context "for the user being admin of objects" do
      before { @group.admins_parent.child_users << @user }
      it "should list the objects the user is directly admin of" do
        subject.should include @group
      end
    end
  end

  describe "#administrated_objects" do
    before do
      @group = create( :group, name: "Administrated Group" )
      @group.find_or_create_admins_parent_group
    end
    subject { @user.administrated_objects }
    it { should be_kind_of Array }
    context "for the user being admin of an object" do
      before { @group.admins_parent.child_users << @user }
      it "should list all objects administrated by the user" do
        @group.admins_parent.should be_kind_of Group
        @group.admins_parent.child_users.should include @user
        subject.should include @group
      end
    end
    context "for the user being an indirect admin of an object" do
      before do
        @sub_group = create( :group, name: "Indirectly Administrated Group" )
        @sub_group.parent_groups << @group
        @group.admins_parent.child_users << @user
      end
      it "should list directly and indirectly administrated objects" do
        subject.should include( @group, @sub_group )
      end
    end
  end

  # Main Admins
  # ------------------------------------------------------------------------------------------

  describe "#main_admin_of?" do
    before do
      @group = create(:group)
    end
    subject { @user.main_admin_of? @group }
    context "for the main_admins_parent_group existing" do
      before { @group.create_main_admins_parent_group }
      context "for the user being a main admin of the object" do
        before { @group.main_admins << @user }
        it { should == true }
      end
      context "for the user being just a regular admin of the object" do
        before { @group.admins << @user }
        it { should == false }
      end
      context "for the user being just a regular member of the object" do
        before { @group << @user }
        it "should be false" do
          @user.member_of?(@group).should be_true # just to make sure
          subject.should == false
        end
      end
    end
  end


  # Guest Status
  # ==========================================================================================

  describe "#guest_of?" do
    before { @group = create( :group ) }
    subject { @user.guest_of? @group }
    context "for the user being not a guest of the given group" do
      it { should == false }
    end
    context "for the user being a guest of the given group" do
      before do
        @group.find_or_create_guests_parent_group
        @group.guests << @user
      end
      it { should == true }
    end
  end


  # Developers
  # ==========================================================================================

  describe "#developer?" do
    subject { @user.developer? }
    describe "for no developers group existing" do
      it { should == false }
    end
    describe "for the user being no member of the developers group" do
      before { Group.create_developers_group }
      it { should == false }
    end
    describe "for the user being member of the developers group" do
      before { Group.create_developers_group.assign_user @user }
      it { should == true }
    end
  end
  describe "#developer = " do
    describe "true" do
      subject { @user.developer = true }
      it "should assign the user to the developers group" do
        @user.should_not be_member_of Group.developers
        subject
        @user.should be_member_of Group.developers
      end
    end
    describe "false" do
      before { @user.developer = true }
      subject { @user.developer = false; time_travel 2.seconds }
      it "should un-assign the user from the developers group" do
        @user.should be_member_of Group.developers
        subject
        @user.should_not be_member_of Group.developers
      end
    end
  end

end