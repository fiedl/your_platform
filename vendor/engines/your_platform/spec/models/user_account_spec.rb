# -*- coding: utf-8 -*-
require 'spec_helper'

describe UserAccount do

  before do
    @user = create(:user_with_account)
    @account = @user.account
  end

  specify "the account should exist at this point" do
    @account.should be 
  end

  describe "#user" do
    subject { @account.user }
    it { should == @user } 
  end

  describe "#id" do
    subject { @account.id }
    it { should_not be_nil }
  end

  describe "#encrypted_password" do
    subject { @account.encrypted_password }
    describe "just after creating the account" do
      it { should_not be_nil }
    end
    describe "after reloading the account from the database" do
      subject { User.find(@user.id).account.encrypted_password }
      it { should_not be_nil }
    end
  end

  describe "#password" do
    subject { @account.password }
    describe "just after creating the account" do
      it { should be_kind_of String }
      it { should be_present }
    end
    describe "after reloading the account from the database" do
      subject { User.find(@user.id).account.password }
      describe "in order to protect the password from being read out" do
        it { should == nil }
      end
    end
  end

  # Welcome Email
  # ==========================================================================================

  # TODO: Do not deliver the welcome email from the model (account.activate),
  # but from the controller.

  describe "Welcome Email: " do
    describe "just after creating the account" do
      subject { ActionMailer::Base.deliveries.last.to_s }
      it { should be_present }
      it "should contain the newly generated password" do
        subject.should include @account.password
        @account.password.should be_kind_of String
        @account.password.should be_present
      end
    end
  end
  
end
