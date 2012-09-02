# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do

  def new_user
    User.new( first_name: "Max", last_name: "Mustermann", alias: "m.mustermann",
              email: "max.mustermann@example.com", create_account: true )
  end

  def create_user_with_account
    User.create( first_name: "John", last_name: "Doe", email: "j.doe@example.com",
                 :alias => "j.doe", create_account: true )
  end

  describe ".create" do
    describe "with account" do
      before { @created_user_with_account = create_user_with_account }
      subject { @created_user_with_account }
      it "should have an initial password set" do
        # This is to avoid the bug of welcome emails with a blank password.
        subject.account.password.should_not be_empty
      end
    end
  end





  before do
    @user = new_user
  end

  subject { @user }

  it { should respond_to( :first_name ) }
  it { should respond_to( :last_name ) }
  it { should respond_to( :name ) }
  it { should respond_to( :alias ) }
  it { should respond_to( :email ) }
  it { should respond_to( :create_account ) }
  it { should respond_to( :groups ) }

  it { should be_valid }

  describe "#memberships" do
    it "should return all UserGroupMemberships of the user" do
      @user.memberships.should == UserGroupMembership.find_all_by_user( @user )
    end
    describe ".with_deleted" do
      it "should return all UserGroupMemberships of the user, including the deleted ones" do
        @user.memberships.with_deleted.should == UserGroupMembership.find_all_by_user( @user ).with_deleted
      end
    end
  end


  describe "before building an account" do

    its(:account) { should be_nil }
    it { should_not have_account }

    describe "with create_account set to 'true' and save" do

      before do
        @user.create_account = true
        @user.save
      end

      it { should have_account }

    end

  end

  describe "after building an account" do

    before do
      @user_account = @user.build_account
    end

    its( :account ) { should be @user_account }
    it { should have_account }

    describe "and deactivating it" do
      before do
        @user.deactivate_account
      end
      
      its(:account) { should be_nil }
      it { should_not have_account }
    end

  end

end

