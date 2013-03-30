require 'spec_helper'

describe Post do

  describe ".create_from_message" do
    before { @message = build(:mail_message_to_group) }
    subject { Post.create_from_message(@message) } 

    it "should create a new Post" do
      Post.count.should == 0
      subject
      Post.count.should == 1
    end

    describe "for an author found in the database" do
      before do
        @author = create( :user )
        @author.email = @message.from.first
        @author.save
      end
      its(:author) { should == @author }
    end

    its(:subject) { should == @message.subject }
    its(:subject) { should be_kind_of String }

    its(:sent_at) { should == @message.date }
    its(:sent_at) { should be_kind_of Time }

    its(:text) { should == @message.body.decoded }

    describe "for an existing group with matching token" do
      before do
        # the email used is sent to test-group@exmaple.com
        @group = create(:group, name: "Test Group")
      end
      its(:group) { should == @group }
    end    
  end

  describe "#author=" do
    before { @post = Post.new }
    
    describe "for a matching user existing: " do
      before { @user = create(:user) }

      describe "for the parameter being a user" do
        subject { @post.author = @user }
        it "should set the author as this user" do
          @post.author.should == nil
          subject
          @post.author.should == @user
        end
      end

      describe "for the parameter being an email string" do
        subject { @post.author = @user.email.to_str }
        it "should set the author User found by the email string" do
          @post.author.should == nil
          subject
          @post.author.should == @user
        end
      end
    end
  end

  describe "#author" do
    before { @post = Post.new }
    subject { @post.author }
    describe "for the author being set as User" do
      before do
        @user = create(:user)
        @post.author = @user
      end
      it { should == @user }
    end
    describe "for the author being given as string" do
      before do
        @user_string = "Foo Bar <foo.bar@example.com>"
        @post.author = @user_string
      end
      it { should == @user_string }
      it { should == @post.external_author }
    end
  end
end
