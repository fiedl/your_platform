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

  describe '#email=' do
    it 'should not raise an exception when set because it is required by devise for an error case' do
      expect{@account.email = 'invalid@example.org'}.to_not raise_error
    end
  end

  describe '#identify_user_account' do
    describe 'with invalid login name' do
      it 'should return nil' do
        UserAccount.identify_user_account('invalid').should be_nil
      end
    end

    describe 'with valid email' do
      it 'should return the user account' do
        expect(UserAccount.identify_user_account(@user.email)).to eq(@account)
      end
    end

    describe 'with valid alias' do
      it 'should return the user account' do
        expect(UserAccount.identify_user_account(@user.alias)).to eq(@account)
      end
    end

    describe 'with valid name' do
      it 'should return the user account' do
        expect(UserAccount.identify_user_account(@user.name)).to eq(@account)
      end
    end
  end

  describe "#auth_token" do
    subject { @account.auth_token }
    describe "just after creating the account" do
      it { should be_present }
      it { should be_kind_of String }
      its(:length) { should >= 40 }
    end
    specify "calling it twice should not change the token" do
      token1 = subject
      token2 = subject
      token1.should == token2
    end
  end
  
  describe ".identify" do
    before do
      @user1 = create :user_with_account, first_name: "John", last_name: "Doe", email: "john.doe@example.com", :alias => "doe"
      @user2 = create :user_with_account, first_name: "James", last_name: "Doe", email: "james.doe@example.com", :alias => "james.doe"
    end
    
    context "for an empty login string" do
      it "should raise an error" do
        expect { UserAccount.identify('') }.to raise_error
      end
    end
    context "if only one user is matching" do
      it "should return the one matching user account" do
        UserAccount.identify("james.doe").should == @user2.account
        UserAccount.identify("james.doe@example.com").should == @user2.account
        UserAccount.identify("John Doe").should == @user1.account
      end
    end
    context "for multiple users with the same last name" do
      before { @user1.update_attributes(:alias => nil) }
      it "should raise an error" do
        expect { UserAccount.identify('doe') }.to raise_error 'identification_not_unique'
      end
    end
    context "if the last name is identical to the alias (bug fix)" do
      before do
        @user1.destroy # since only @user2 should be present for this test 
        @user2.update_attribute(:alias, 'doe')
      end
      specify "prerequisites" do
        @user2.alias.downcase.should == @user2.last_name.downcase
      end
      it "should return the one matching user" do
        UserAccount.identify('doe').should == @user2.account
      end
    end
    context "for several users having the same last name and one of them having the last name as alias (bug fix)" do
      specify "prerequisistes" do
        @user1.last_name.downcase.should == @user1.alias.downcase
        @user2.last_name.downcase.should == @user1.last_name.downcase
      end
      it "should return the user identified by the alias" do
        UserAccount.identify("doe").should == @user1.account
      end
    end
  end
end
