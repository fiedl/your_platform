require 'spec_helper'

describe GuestUser do
  describe "#find_or_create('John Doe', 'j.doe@example.com')" do
    subject { GuestUser.find_or_create("John Doe", "j.doe@example.com") }

    describe "if the user does not exist" do
      it "should create the user" do
        User.count.should == 0
        subject
        User.count.should == 1
        User.first.first_name.should == "John"
        User.first.last_name.should == "Doe"
        User.first.email.should == "j.doe@example.com"
        User.first.account.should be_nil
      end
      it "should return the newly created user" do
        subject.should == GuestUser.first
      end
    end
    describe "if the user has an account" do
      before do
        @user = User.create first_name: "John", last_name: "Doe", email: "j.doe@example.com"
        @user.activate_account
      end
      it "should not create a duplicate user" do
        User.count.should == 1
        subject
        User.count.should == 1
      end
      it "should not return the existing user since it is not guest" do
        subject.should == nil
      end
    end
    describe "if the user exists but has no account" do
      before { @user = User.create first_name: "John", last_name: "Doe", email: "j.doe@example.com" }
      it "should not create a duplicate user" do
        User.count.should == 1
        subject
        User.count.should == 1
      end
      it "should return the existing guest user" do
        subject.should == @user
      end
    end
  end

  describe "#find_or_create('', 'j.doe@example.com)" do
    subject { GuestUser.find_or_create("", "j.doe@example.com") }

    describe "if the user does not exist" do
      it "should create the user" do
        User.count.should == 0
        subject
        User.count.should == 1
        User.first.first_name.to_s.should == ""
        User.first.last_name.should == "J.doe"
        User.first.email.should == "j.doe@example.com"
        User.first.account.should be_nil
      end
      it "should return the newly created user" do
        subject.should == GuestUser.first
      end
    end
    describe "if the user has an account" do
      before do
        @user = User.create first_name: "John", last_name: "Doe", email: "j.doe@example.com"
        @user.activate_account
      end
      it "should not create a duplicate user" do
        User.count.should == 1
        subject
        User.count.should == 1
      end
      it "should not return the existing user since it is not guest" do
        subject.should == nil
      end
    end
    describe "if the user exists but has no account" do
      before { @user = User.create first_name: "John", last_name: "Doe", email: "j.doe@example.com" }
      it "should not create a duplicate user" do
        User.count.should == 1
        subject
        User.count.should == 1
      end
      it "should return the existing guest user" do
        subject.should == @user
      end
    end
  end

  describe "#find_or_create('John Doe', '')" do
    subject { GuestUser.find_or_create("John Doe", "") }

    describe "if the user does not exist" do
      it "should create the user" do
        User.count.should == 0
        subject
        User.count.should == 1
        User.first.first_name.should == "John"
        User.first.last_name.should == "Doe"
        User.first.email.to_s.should == ""
        User.first.account.should be_nil
      end
      it "should return the newly created user" do
        subject.should == GuestUser.first
      end
    end

    describe "if there is a user with the same name, but with email and account" do
      before do
        @user = User.create first_name: "John", last_name: "Doe", email: "j.doe@example.com"
        @user.activate_account
      end
      it "should create a new user" do
        User.count.should == 1
        subject
        User.count.should == 2
      end
      it "should not return the existing user since it is not guest" do
        subject.id.should_not == @user.id
      end
      it { should == GuestUser.last }
    end

    describe "if there is a user with the same name, without email and without account" do
      before { @user = User.create(first_name: "John", last_name: "Doe").becomes(GuestUser) }
      it "should return that user" do
        subject.should == @user
      end
      it "should not create a duplicate" do
        User.count.should == 1
        subject
        User.count.should == 1
      end
    end


  end
end