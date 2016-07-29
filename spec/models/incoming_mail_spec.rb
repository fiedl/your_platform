require 'spec_helper'

describe IncomingMail do
  before { RawMessageUploader.enable_processing = true }
  after { RawMessageUploader.enable_processing = false }
  after { IncomingMail.last.raw_message_file.remove! }

  describe ".create_from_message" do
    subject { IncomingMail.create_from_message example_raw_message }

    let(:example_raw_message) { %{
      From: john@example.com
      To: all-developers@example.com
      Subject: Great news for all developers!
      Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

      Free drinks this evening!
    }.gsub("  ", "") }

    it { should be_kind_of IncomingMail }
    its(:from) { should == "john@example.com" }
    its(:to) { should == "all-developers@example.com" }
    its(:destinations) { should == ["all-developers@example.com"] }
    its(:subject) { should == "Great news for all developers!" }
    its(:message_id) { should == "579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com" }
    it 'persists the raw message' do
      subject.raw_message.should be_kind_of String
      subject.raw_message.should include "From: john@example.com"
      subject.raw_message.should include "To: all-developers@example.com"
      subject.raw_message.should include "Subject: Great news for all developers!"
      subject.raw_message.should include "Free drinks this evening!"
    end
    it 'uploads a file' do
      File.file?(subject.raw_message_file.path).should be_true
    end

    describe "given an in-reply-to header" do
      subject { IncomingMail.create_from_message reply_to_raw_message }
      let(:reply_to_raw_message) { %{
        From: john@example.com
        To: all-developers@example.com
        Subject: Re: Great news for all developers!
        In-Reply-To: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

        Free drinks this evening!
      }.gsub("  ", "") }
      its(:in_reply_to_message_id) { should == "579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com" }
      its('in_reply_to.to_a') { should == [] }
      describe "when the reply-to message exists" do
        before { @first_message = IncomingMail.create_from_message example_raw_message }
        its('in_reply_to.to_a') { should == [@first_message] }
      end
    end

    describe "given a CC" do
      let(:example_raw_message) { %{
        From: john@example.com
        To: all-developers@example.com
        CC: all-testers@example.com
        Subject: Great news for all developers!
        Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

        Free drinks this evening!
      }.gsub("  ", "") }
      its(:to) { should == "all-developers@example.com" }
      its(:cc) { should == "all-testers@example.com" }
      its(:destinations) { should == ["all-developers@example.com", "all-testers@example.com"] }
    end

    describe "given an Envelope-To" do
      let(:example_raw_message) { %{
        From: john@example.com
        To: all-developers@example.com
        CC: all-testers@example.com
        Envelope-To: all-developers@example.com
        Subject: Great news for all developers!
        Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

        Free drinks this evening!
      }.gsub("  ", "") }
      its(:envelope_to) { should == "all-developers@example.com" }
      its(:to) { should == "all-developers@example.com" }
      its(:cc) { should == "all-testers@example.com" }
      its(:destinations) { should == ["all-developers@example.com"] }
    end

    describe "given an Envelope-To which is not in the To (maybe BCC)" do
      let(:example_raw_message) { %{
        From: john@example.com
        To: all-developers@example.com
        CC: all-testers@example.com
        Envelope-To: all-secret-recipients@example.com
        Subject: Great news for all developers!
        Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

        Free drinks this evening!
      }.gsub("  ", "") }
      its(:envelope_to) { should == "all-secret-recipients@example.com" }
      its(:to) { should == "all-developers@example.com" }
      its(:cc) { should == "all-testers@example.com" }
      its(:destinations) { should == ["all-secret-recipients@example.com"] }
    end

    describe "given a Stmp-Envelope-To (differen header name!)" do
      let(:example_raw_message) { %{
        From: john@example.com
        To: all-developers@example.com
        CC: all-testers@example.com
        Smtp-Envelope-To: all-developers@example.com
        Subject: Great news for all developers!
        Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

        Free drinks this evening!
      }.gsub("  ", "") }
      its(:envelope_to) { should == "all-developers@example.com" }
      its(:to) { should == "all-developers@example.com" }
      its(:cc) { should == "all-testers@example.com" }
      its(:destinations) { should == ["all-developers@example.com"] }
    end
  end

  describe "#process" do
    subject { incoming_mail.process }
    let(:incoming_mail) { IncomingMail.create_from_message example_raw_message }
    let(:example_raw_message) { %{
      From: john@example.com
      To: all-developers@example.com
      Subject: Great news for all developers!
      Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

      Free drinks this evening!
    }.gsub("  ", "") }

    it { should be_kind_of Array}
  end
end
