# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do
  before do
    @user = User.new( first_name: "Max", last_name: "Mustermann", alias: "m.mustermann",
                      email: "max.mustermann@example.com", create_account: true )
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
  
  describe "before building an account" do

    describe "should have no user account" do
      its(:account) { should be_nil }
      it { should_not have_account }
    end

    describe "with create_account set to 'true'" do

      before do
        @user.create_account = true
        @user.save
      end

      describe "should build an account automatically on save" do
        it { should have_account }
      end

    end

  end

  describe "after building an account" do

    before do
      @user_account = @user.build_account
    end

    describe "should have an account" do
      its( :account ) { should be @user_account }
      it { should have_account }
    end

    describe "should have no account after deactivating the account" do
      before do
        @user.deactivate_account
      end
      
      specify { @user.account( force_reload: true ).should be_nil }
      it { should_not have_account }
    end

  end

end

