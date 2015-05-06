require 'spec_helper'

describe ReceivedMail do
  
  let(:sender_user) { create :user }
  let(:recipient_group) {
    group = create :group
    group.email = 'example-group@example.com'
    group.save
    group
  }
  let(:message) { 
    "From: #{sender_user.name} <#{sender_user.email}>\n" +
    "To: #{recipient_group.email}\n" +
    "Subject: Test Mail\n\n" +
    "This is a simple text message."
  }
  let(:mail) { ReceivedMail.new(message) }
  

  describe "#sender_email" do
    subject { mail.sender_email }
    it { should == sender_user.email }
  end
  describe "#sender" do
    subject { mail.sender }
    it { should == sender_user }
  end
  
  describe "#recipient_emails" do
    subject { mail.recipient_emails }
    it { should == [recipient_group.email] }
  end
  describe "#recipients" do
    subject { mail.recipients }
    it { should == [recipient_group] }
  end
  
  describe "#subject" do
    subject { mail.subject }
    it { should == "Test Mail" }
  end

  describe "#content" do
    subject { mail.content }
    it { should == "This is a simple text message." }
  end
  
  describe "for an unknown sender" do
    let(:message) { 
      "From: Unknown Sender <unknown@example.com>\n" +
      "To: #{recipient_group.email}\n" +
      "Subject: Test Mail\n\n" +
      "This is a simple text message."
    }
    let(:mail) { ReceivedMail.new(message) }

    describe "#sender_email" do
      subject { mail.sender_email }
      it { should == "unknown@example.com" }
    end
    describe "#sender" do
      subject { mail.sender }
      it { should == nil }
    end
    describe "#sender_string" do
      subject { mail.sender_string }
      it { should == "Unknown Sender <unknown@example.com>" }
    end
    
    describe "#recipients" do
      subject { mail.recipients }
      it { should == [recipient_group] }
    end
  end

  describe "for a sender with known name but unknown address" do
    let(:message) { 
      "From: #{sender_user.name} <unknown@example.com>\n" +
      "To: #{recipient_group.email}\n" +
      "Subject: Test Mail\n\n" +
      "This is a simple text message."
    }
    let(:mail) { ReceivedMail.new(message) }

    describe "#sender_email" do
      subject { mail.sender_email }
      it { should == "unknown@example.com" }
    end
    describe "#sender" do
      subject { mail.sender }
      it { should == sender_user }
    end
    describe "#sender_string" do
      subject { mail.sender_string }
      it { should == "#{sender_user.name} <unknown@example.com>" }
    end
    describe "#sender_name" do
      subject { mail.sender_name }
      it { should == sender_user.name }
    end
    
    describe "#recipients" do
      subject { mail.recipients }
      it { should == [recipient_group] }
    end
  end

end