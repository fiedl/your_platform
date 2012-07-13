# -*- coding: utf-8 -*-
require 'spec_helper'

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

    describe "should still be referenced by the associated user" do
      it { should be @user.account }
    end

    describe "really needs to have a password set" do
      #is this true for every save? Or just after creation like here --JRe
      its( :password_digest ) { should_not be_nil }
      its( :password_digest ) { should_not be_empty }
    end

    describe "should be autosaved" do
      #@user.id.should_not be_nil
      its( :id ) { should_not be_nil }
    end

    describe "should send a welcome email" do

      subject { ActionMailer::Base.deliveries.last }

      describe "on save" do
        it { should_not be_nil }
      end

      describe "and it should contain the password" do
        # This would be the code to retrieve the password:
        #      email = ActionMailer::Base.deliveries.last
        #      line = email.to_s.lines.find { |s| s.starts_with? "Passwort: " }
        #      @password = line.split(' ').last
        specify { @user_account.password.should_not be_nil }
        its(:to_s) { should include @user_account.password }
      end

    end

  end

  describe "#password" do    # use "." for class methods, "#" for instance methods in rspec.

    before do
      @user.save
    end

    describe "should be readable just after password generation" do
      its( :password ) { should_not be_nil }
    end

    it "should not be readable after retrieving the user from the database" do
      @user = nil
      @user = User.last
      @user.account.password.should be_nil
    end

  end

  describe ".authenticate" do   # use "." for class methods, "#" for instance methods in rspec.

    before do
      @user.save
      @login_string = @user.alias
      @password = @user_account.password
    end

    describe "with valid password" do
      its( :user ) { should eq UserAccount.authenticate( @login_string, @password ) }
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
