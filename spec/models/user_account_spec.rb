# -*- coding: utf-8 -*-
require 'spec_helper'

describe UserAccount do

  before do
    @user = User.new( first_name: "Max", last_name: "Mustermann", alias: "m.mustermann",
                      email: "max.mustermann@example.com" )
    @user_account = @user.activate_account
  end

  subject { @user_account }

  it { should be }

  it { should respond_to :user }

  describe 'after saving' do

    before do
      @user.save
    end

    it { should be @user.account }
      
    #is this true for every save? Or just after creation like here --JRe
    its( :encrypted_password ) { should_not be_blank }
    its( :id ) { should_not be_nil }

    describe 'should send a welcome email' do

      subject { ActionMailer::Base.deliveries.last }

      describe 'on save' do
        it { should_not be_nil }
      end

      describe 'and it should contain the password' do
        specify { @user_account.password.should_not be_blank }
        its(:to_s) { should include @user_account.password }
      end
    end
  end

  describe '#password' do    # use "." for class methods, "#" for instance methods in rspec.

    before do
      @user.save
    end

    describe 'just after generation' do
      its( :password ) { should_not be_nil }
    end

    it 'should not be readable after retrieving the user from the database' do
      @user = nil
      @user = User.last
      @user.account.password.should be_nil
    end

  end
end
