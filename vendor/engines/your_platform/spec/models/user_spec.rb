# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do

  before do 
    @user = create( :user )
    @user.save
  end

  subject { @user }

  # Validation
  # ==========================================================================================

  it { should be_valid }


  # Basic Properties
  # ==========================================================================================

  describe "accessible attributes" do
    subject { @user }
    [ :first_name, :last_name, :alias, :email, :create_account, :female, :add_to_group ].each do |attr|
      it { should respond_to( attr ) }
      it { should respond_to( "#{attr}=".to_sym ) }
    end
  end

  describe "#name" do
    subject { @user.name }
    it { should == "#{@user.first_name} #{@user.last_name}" }
  end

  describe "#capitalize_name" do
    before do
      @user.first_name = "john"
      @user.last_name = "doe"
      @user.capitalize_name
      @user.save
    end
    it "should capitalize the first_name and last_name" do
      @user.first_name.should == "John"
      @user.last_name.should == "Doe"
      @user.name.should == "John Doe"
    end
  end

  describe "#title" do
    subject { @user.title }
    # the title is likely to be overridden in the main application. Therefore, here are
    # just a few vague tests.
    it { should include( @user.last_name ) }
    it { should_not be_empty }
  end

  describe "#gender" do
    it "should return :female if the user is female" do
      @user.female = true
      @user.gender.should == :female
    end
    it "should return :male if the user is not female" do
      @user.female = false
      @user.gender.should == :male
    end
  end

  describe "#gender=" do
    it "should set :female to true if the gender is female" do
      @user.gender = :female
      @user.female?.should == true
    end
    it "should set :female to false if the gender is male" do
      @user.gender = :male
      @user.female?.should == false
    end
    it "should set :female to false if the gender is something else" do
      @user.gender = :something_else
      @user.female?.should == false
    end
  end

  
  # Associated Objects
  # ==========================================================================================

  # Alias
  # ------------------------------------------------------------------------------------------

  describe "#alias" do
    subject { @user.alias }
    it { should be_kind_of( UserAlias ) }
    it { should_not be_empty }
  end
  
  describe "#alias=" do
    it "should set the alias attribute" do
      @user.alias = "New Alias"
      @user.alias.should == "New Alias"
    end
  end

  
  # User Account
  # ------------------------------------------------------------------------------------------

  context "for a user with account" do
    before { @user_with_account = create( :user_with_account ) }
    subject { @user_with_account }

    describe "#has_account?" do
      subject { @user_with_account.has_account? }
      it { should == true }
    end

    describe "#activate_account" do
      it "should keep the existing account" do
        @existing_account = @user_with_account.account
        @user_with_account.activate_account
        @user_with_account.account.should == @existing_account
      end
    end

    describe "#deactivate_account" do
      it "should destroy the existing account" do
        @user_with_account.account.should_not be_nil
        @user_with_account.deactivate_account
        @user_with_account.account.should be_nil
        @user_with_account.has_account?.should == false
      end
    end

    specify "the new user should have an initial password" do
      # This is to avoid the bug of welcome emails with a blank password.
      subject.account.password.should_not be_empty
    end
  end

  context "for a user without account" do
    before { @user_without_account = create( :user, :create_account => false ) }

    describe "#has_account?" do
      subject { @user_without_account.has_account? }
      it { should == false }
    end

    describe "#activate_account" do
      it "should create an account" do
        @user_without_account.account.should == nil
        @user_without_account.activate_account
        @user_without_account.account.should be_kind_of( UserAccount )
        @user_without_account.should_not be_nil
      end
    end

    describe "#deactivate_account" do
      it "should raise an error, since no account exists" do
        expect { @user_without_account.deactivate_account }.to raise_error
      end
    end
  end

  describe "#create_account attribute" do
    describe "#create_account == true" do
      it "should cause the user to be created with account" do
        create( :user, create_account: true ).account.should_not be_nil
      end
    end
    describe "#create_account == false" do
      it "should cause the user to be created without account" do
        create( :user, create_account: false ).account.should be_nil
      end
    end
    describe "#create_account == 0" do
      it "should cause the user to be created without account" do
        create( :user, create_account: 0 ).account.should be_nil
      end
    end
    describe "#create_account == 1" do
      it "should cause the user to be created with account" do
        create( :user, create_account: 1 ).account.should_not be_nil
      end
    end
    describe "#create_account == '0'" do # for HTML forms
      it "should cause the user to be created without account" do
        create( :user, create_account: "0" ).account.should be_nil
      end
    end
    describe "#create_account == '1'" do # for HTML forms
      it "should cause the user to be created with account" do
        create( :user, create_account: "1" ).account.should_not be_nil
      end
    end
    describe "#create_account == ''" do
      it "should cause the user to be created without account" do
        create( :user, create_account: "" ).account.should be_nil
      end
    end
  end


  # Groups
  # ------------------------------------------------------------------------------------------

  describe "#groups" do
    before do
      @group = create( :group )
      @everyone_group = Group.everyone
      @group.parent_groups << @everyone_group
      @user.save
      @user.parent_groups << @group
      @user.reload
    end
    subject { @user.groups }
    it "should include the groups the user is a direct member of" do
      subject.should include( @group )
    end
    it "should include the groups the user is an indirect member of" do
      subject.should include( Group.everyone )
    end
    it "should return all ancestor groups" do
      subject.should == @user.ancestor_groups
    end
  end

  describe "#add_to_group attribute" do
    before do
      @group = create( :group )
    end
    describe "#add_to_group == nil" do
      subject { create( :user, :add_to_group => nil ) }
      it "should not add the user to a group during creation" do
        subject.parent_groups.should_not include( @group )
      end
    end
    describe "#add_to_group == some_group" do
      subject { create( :user, :add_to_group => @group ) }
      it "should add the user to the group during creation" do
        subject.parent_groups.should include( @group )
      end
    end
    describe "#add_to_group == some_group_id" do
      subject { create( :user, :add_to_group => @group.id ) }
      it "should add the user to the group during creation" do
        subject.parent_groups.should include( @group )
      end
    end
  end


  # Corporations
  # ------------------------------------------------------------------------------------------

  describe "#corporations" do
    before do
      @corporation = create( :corporation )
      @subgroup = create( :group ); @subgroup.parent_groups << @corporation
      @user.save
      @user.parent_groups << @subgroup
      @user.reload
    end
    subject { @user.corporations }
    it "should return an array of the user's corporations" do
      subject.should == [ @corporation ]
    end
    it "should return an array of Corporation-type objects" do
      subject.should be_kind_of Array
      subject.first.should be_kind_of Corporation
    end
  end

  
  # Memberships
  # ------------------------------------------------------------------------------------------

  describe "#memberships" do
    before do
      @group = create( :group )
      @group.child_users << @user
      @membership = UserGroupMembership.find_by( user: @user, group: @group )
    end
    subject { @user.memberships }
    it "should return an array of the user's memberships" do
      subject.should == [ @membership ]
    end
    it "should be the same as UserGroupMembership.find_all_by_user" do
      subject.should == UserGroupMembership.find_all_by_user( @user )
    end
    it "should allow to chain other ActiveRelation scopes, like `with_deleted`" do
      subject.with_deleted.should == [ @membership ]
    end
  end


  # Relationships
  # ------------------------------------------------------------------------------------------

  describe "#relationships" do
    before do
      @other_user = create( :user )
      @relationship = create( :relationship, who: @user, of: @other_user )
    end
    subject { @user.relationships }
    it "should return the relationships of the user" do
      subject.should == [ @relationship ]
    end
  end


  # Workflows
  # ------------------------------------------------------------------------------------------

  describe "#workflows" do
    before do 
      @group = create( :group )      
      @workflow = create( :workflow ); @workflow.parent_groups << @group
      @user.save
      @user.parent_groups << @group
      @user.reload
    end
    subject { @user.workflows }
    it "should return an array of all workflows of all groups of the user" do
      subject.should == [ @workflow ]
    end
  end


  # User Identification and Authentification
  # ==========================================================================================

  describe ".identify" do
    before { @user.save; @user.reload }
    describe "with a valid and matching login_string" do
      subject { User.identify( @user.alias ) }
      it { should == @user }
    end
    describe "with an empty login string" do
      subject { User.identify( "" ) }
      it { should == nil }
    end
    describe "with a nonsense login string" do
      subject { User.identify( "schnidddlprmpf!" ) }
      it { should == nil }
    end
  end

  describe ".authenticate" do
    before do
      @user.activate_account
      @user.account.password = "correct_password"
      @user.save
    end
    describe "with the correct password" do
      subject { User.authenticate( @user.alias, "correct_password" ) }
      it { should == @user }
    end
    describe "with the wrong password" do
      subject { User.authenticate( @user.alias, "wrong_password" ) }
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
    describe "with a wrong login_string" do
      subject { User.authenticate( "wrong_login_string", "some_password" ) }
      it "should raise an error" do
        expect { subject }.to raise_error
      end
    end
    describe "for a user without account" do
      before { @user.deactivate_account }
      subject { User.authenticate( @user.alias, "correct_password" ) }
      it "should raise an error" do
        expect { subject }.to raise_error
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


  # Finder Methods
  # ==========================================================================================

  describe ".find_all_by_identification_string" do
    before do
      @user.first_name = "Some First Name"
      @user.last_name = "UniqueLastName" 
      @user.email = "unique@example.com"
      @user.alias = "s.unique"
      @user.save
    end
    describe "for a given alias" do
      subject { User.find_all_by_identification_string( @user.alias ) }
      it { should == [ @user ] }
    end
    describe "for a given last_name" do
      subject { User.find_all_by_identification_string( @user.last_name ) }
      it { should == [ @user ] }
    end
    describe "for a given name" do
      subject { User.find_all_by_identification_string( "#{@user.first_name} #{@user.last_name}" ) }
      it { should == [ @user ] }
    end
    describe "for a given email" do
      subject { User.find_all_by_identification_string( @user.email ) }
      it { should == [ @user ] }
    end
    describe "for given nonsense" do
      subject { User.find_all_by_identification_string( "f kas#dfk aoefak!" ) }
      it { should == [] }
    end
  end

  describe ".find_by_title" do
    before do
      @user.first_name = "Johnny"
      @user.last_name = "Doe"
      @user.save
      @title = @user.title 
    end
    specify { @title.should_not be_empty }
    subject { User.find_by_title( @title ) }
    it "should find the user by its title" do
      subject.should == @user 
    end
  end

  describe ".find_all_by_name" do
    before do
      @user = create( :user )
    end
    subject { User.find_all_by_name( @user.name ) }
    it { should include( @user ) }
    it "should be case-insensitive" do
      User.find_all_by_name( @user.name.upcase ).should include( @user )
      User.find_all_by_name( @user.name.downcase ).should include( @user )
    end
  end

  describe ".find_all_by_email" do
    before do
      @user = create( :user )
    end
    subject { User.find_all_by_email( @user.email ) }
    it { should include( @user ) }
    it "should be case-insensitive" do
      User.find_all_by_email( @user.email.upcase ).should include( @user )
      User.find_all_by_email( @user.email.downcase ).should include( @user )
    end
  end

end

