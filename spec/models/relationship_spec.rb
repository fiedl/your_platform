require 'spec_helper'

describe Relationship do

  before do 
    @user1 = create( :user, first_name: "John", last_name: "Doe" )
    @user2 = create( :user, first_name: "Sue", last_name: "Doe" )
    @user3 = create( :user, first_name: "Another", last_name: "User" )
    @relationship = Relationship.create( user1: @user1, user2: @user2, name: "brother" ) 
  end

  describe "#who" do
    subject { @relationship.who }
    it { should == @relationship.user1 }
    it { should == @user1 }
  end
  describe "#who=" do
    subject { @relationship.who = @user3 }
    it "should assign the new user" do
      subject
      @relationship.user1.should == @user3
    end
  end

  describe "#is" do
    subject { @relationship.is }
    it { should == @relationship.name }
    it { should == "brother" }
  end
  describe "#is=" do
    subject { @relationship.is = "beloved brother" }
    it "should assign the new name of the relationship" do
      subject
      @relationship.name.should == "beloved brother"
    end
  end

  describe "#of" do
    subject { @relationship.of }
    it { should == @relationship.user2 }
    it { should == @user2 }
  end
  describe "#of=" do
    subject { @relationship.of = @user3 }
    it "should assign the new user" do
      subject
      @relationship.user2.should == @user3
    end
  end

  describe "#add" do
    describe "for adding the first relationship" do
      before do 
        Relationship.delete_all
      end
      subject { Relationship.add( who: @user1, is: "beloved brother", of: @user2 ) }
      it "should create the relationship between these users" do
        @relationship = subject
        @user1.relationships.should include( @relationship )
        @user2.relationships.should include( @relationship )
      end
    end
    describe "for adding the second relationship" do
      subject { Relationship.add( who: @user1, is: "godfather of the child", of: @user2 ) }
      it "should create the relationship between these users" do
        @second_relationship = subject
        @user1.relationships.should include( @second_relationship )
        @user2.relationships.should include( @second_relationship )
      end
    end
    describe "for adding a circular relationship" do
      subject { Relationship.add( who: @user2, is: "employee", of: @user1 ) }
      it "should create the relationship" do
        @circular_relationship = subject
        @user1.relationships.should include( @relationship, @circular_relationship )
        @user2.relationships.should include( @relationship, @circular_relationship )
      end
    end
  end

  describe "#who_by_title" do
    subject { @relationship.who_by_title }
    it "should return the title of the who-user" do
      subject.should == @relationship.who.title
      subject.should == @relationship.user1.title
    end
  end
  describe "#who_by_title=" do
    subject { @relationship.who_by_title = @user3.title }
    it "should assign the new user as the who-user, finding him by his title" do
      subject
      @relationship.who.should == @user3
      @relationship.user1.should == @user3
    end
  end

  describe "#of_by_title" do
    subject { @relationship.of_by_title }
    it "should return the title of the of-user" do
      subject.should == @relationship.of.title
      subject.should == @relationship.user2.title
    end
  end
  describe "#of_by_title=" do
    subject { @relationship.of_by_title = @user3.title }
    it "should assign the new user as the of-user, finding him by his title" do
      subject
      @relationship.of.should == @user3
      @relationship.user2.should == @user3
    end
  end

end
