# -*- coding: utf-8 -*-
require 'spec_helper'

describe Post do 

  describe ".create_from_message" do
    describe "for text-only messages" do

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

      it "should store the entire message for later re-deliveries" do
        subject.entire_message.should == @message
      end

      describe "for an existing group with matching token" do
        before do
          # the email used is sent to test-group@exmaple.com
          @group = create(:group, name: "Test Group")
        end
        its(:group) { should == @group }
      end
    end
  end

  describe ".create_from_message#text" do
    subject { Post.create_from_message(@message).text }
    describe "for text-only messages" do
      before { @message = build(:mail_message_to_group) }
      it { should == @message.body.decoded }
    end
    describe "for html messages" do
      before { @message = build(:html_mail_message) }
      it "should not include mail headers" do
        subject.should_not include("Return-Path:")
      end
      it "should not include multipart separators" do
        subject.should_not include("--Apple-Mail=") 
      end
      it "should include html tags" do
        subject.should include("<div>")
      end
      it "should include the text" do
        # have a look at the spec/factories/mail_message/html_email.eml file.
        subject.should include("Liebe Freunde",
                               "es ist mir ein besonderes Vergnügen",
                               "Viele Grüße!",
                               "Fiedl Z! E06") 
      end
      it "should be UTF-8 encoded" do
        subject.encoding.to_s.should == "UTF-8"
      end
      it "should not include html, head or body tag, since this would cause problems embedded in an html document" do
        subject.should_not include "<html"
        subject.should_not include "<head"
        subject.should_not include "<body"
      end
    end
  end

  describe ".create_from_message#text_without_html_tags" do
    subject { Post.create_from_message(@message).text_without_html_tags }
    describe "for html messages" do
      before { @message = build(:html_mail_message) }
      it "should include the text" do
        # have a look at the spec/factories/mail_message/html_email.eml file.
        subject.should include("Liebe Freunde",
                               "es ist mir ein besonderes Vergnügen",
                               "Viele Grüße!",
                               "Fiedl Z! E06") 
      end
      it "should not include html tags" do
        subject.should_not include "<html"
        subject.should_not include "<body"
        subject.should_not include "<div"
      end
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

  
  # Delivering Post as Email to All Group Members
  # ==========================================================================================
  
  describe "Delivering Group Mails: " do
    before do
      @message = build(:mail_message_to_group)
      # the email used is sent to test-group@exmaple.com
      @group = create(:group, name: "Test Group")
      @group.child_users << create(:user) << create(:user)
      @users = @group.child_users
      @post = Post.create_from_message(@message)
    end

    describe "#messages_to_deliver_to_mailing_list_members" do
      subject { @post.messages_to_deliver_to_mailing_list_members }
      
      it "should be an Array of Mail Messages" do
        subject.should be_kind_of Array
        subject.first.should be_kind_of Mail
      end
      it "should contain one message per group member" do
        subject.count.should == @users.count
      end
    end

    describe "#modified_subject" do
      subject { @post.modified_subject }
      describe "for a clean subject" do
        before { @post.subject = "My Fancy Subject" }
        it { should == "[Test Group] My Fancy Subject" }
      end
      describe "for a Re: subject" do
        before { @post.subject = "Re: [Test Group] My Fancy Subject" }
        it { should == "Re: [Test Group] My Fancy Subject" }
      end
    end

    describe "#mailing_list_footer" do
      subject { @post.mailing_list_footer }
      it { should include @group.name }
      it "should containt the group's url" do
        @group.url.present?.should == true
        subject.should include @group.url
      end
    end

    describe "#message_for_email_delivery_to_user" do
      before { @user = @users.first }
      subject { @post.message_for_email_delivery_to_user(@user) }
      
      it { should be_kind_of Mail }
      it "should preserve multipart character" do
        subject.multipart?.should == @message.multipart?
      end
      it "should have the modified subject" do
        subject.subject.should == @post.modified_subject
      end
      it "should only have the given user as recipient" do
        subject.to.count.should == 1
        subject.to.first.should include @user.email
      end
      it "should contain the mailing list footer" do
        subject.to_s.should include @post.mailing_list_footer
      end
    end
  end

end
