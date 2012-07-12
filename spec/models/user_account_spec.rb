# -*- coding: utf-8 -*-
require 'spec_helper'

describe User do

  before do
    @user = User.new( first_name: "John", last_name: "Doe", alias: "j.doe",
                      email: "john.doe@example.com" )
  end

  subject { @user }

  describe "before building an account" do

    it "should have no user account" do
      @user.account.should == nil
      @user.has_account?.should be_false
    end

    describe "with create_account == true" do

      before do
        @user.create_account = true
      end

      it "should build an account automatically on save" do
        @user.save
        @user.has_account?.should be_true
      end

    end

  end

  describe "after building an account" do

    before do
      @user_account = @user.build_account
    end

    it "should have an account" do
      @user.account.should == @user_account
      @user.has_account?.should be_true
    end

    it "should have no account after deactivating the account" do
      @user.deactivate_account
      @user.account( force_reload: true ).should == nil
      @user.has_account?.should be_false
    end

  end

end

describe UserAccount do

  before do
    @user = User.new( first_name: "Max", last_name: "Mustermann", alias: "m.mustermann",
                      email: "max.mustermann@example.com" )
    @user_account = @user.build_account
  end

  subject { @user_account }

  it { should be }

  it { should respond_to :password_digest }
  it { should respond_to :authenticate }
  it { should respond_to :user }

  describe "after saving" do

    before do
      @user.save
    end

    it "should still be a reference to the associated account" do
      @user_account.should == @user.account
    end

    it "really needs to have a password set" do
      @user_account.password_digest.should_not == nil
      @user_account.password_digest.should_not == ""
    end

    it "should be autosaved" do
      @user.id.should_not == nil
      @user.account.id.should_not == nil
    end

    describe "welcome email" do

      subject { ActionMailer::Base.deliveries.last }

      it "should be sent on save" do
        subject.should_not == nil
      end

      it "should contain the password" do
        # This would be the code to retrieve the password:
        #      email = ActionMailer::Base.deliveries.last
        #      line = email.to_s.lines.find { |s| s.starts_with? "Passwort: " }
        #      @password = line.split(' ').last
        @user_account.password.should_not == nil
        subject.to_s.include?( @user_account.password ).should be_true
      end

    end

  end

  describe "#password" do    # use "." for class methods, "#" for instance methods in rspec.

    before do
      @user.save
    end

    it "should be readable just after password generation" do
      @user_account.password.should_not == nil
    end

    it "should not be readable after retreaving the user from the database" do
      @user = nil
      @user = User.last
      @user.account.password.should == nil
    end

  end

  describe ".authenticate" do   # use "." for class methods, "#" for instance methods in rspec.

    before do
      @user.save
      @login_string = @user.alias
      @password = @user_account.password
    end

    describe "with valid password" do
      its( :user ) { should == UserAccount.authenticate( @login_string, @password ) }
    end

    describe "with invalid password" do
      let( :user_for_invalid_password ) { UserAccount.authenticate( @login_string, "invalid" ) }

      it "should raise an error" do
        expect { user_for_invalid_password }.should raise_error RuntimeError
      end
    end

    describe "with invalid login string" do
      let( :user_for_invalid_login ) { UserAccount.authenticate( "invalid", @password ) }

      it "should raise an error" do
        expect { user_for_invalid_login }.should raise_error RuntimeError
      end
    end

  end


end
