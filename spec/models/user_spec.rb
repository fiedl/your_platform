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

  it { should be_valid }

  describe "return value of authenticate method" do
    before do 
      @user.save
      email = ActionMailer::Base.deliveries.last
      line = email.to_s.lines.find { |s| s.starts_with? "Passwort: " }
      @password = line.split(' ').last
    end
    
    let( :found_user ) { User.find_by_alias @user.alias }

    describe "with valid password" do
      it { should == UserAccount.authenticate( @user.alias, @password ) }
    end

    describe "with invalid password" do
      let( :user_for_invalid_password ) { UserAccount.authenticate(@user.alias, "invalid") }

      it "should raise an error" do
        expect { user_for_invalid_password }.should raise_error RuntimeError
      end
    end

    describe "with invalid login string" do
      let( :user_for_invalid_login ) { UserAccount.authenticate("invalid", @password) }

      it "should raise an error" do
        expect { user_for_invalid_login }.should raise_error RuntimeError
      end
    end

  end

end
