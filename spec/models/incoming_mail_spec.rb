require 'spec_helper'

describe IncomingMail do
  before { RawMessageUploader.enable_processing = true }
  after { RawMessageUploader.enable_processing = false }

  describe ".create_from_message" do
    let(:example_raw_message) { %{
      From: john@example.com
      To: all-developers@example.com
      Subject: Great news for all developers!

      Free drinks this evening!
    }.gsub("      ", "") }
    subject { IncomingMail.create_from_message example_raw_message }
    after { IncomingMail.last.raw_message_file.remove! }

    it { should be_kind_of IncomingMail }
    its(:from) { should == "john@example.com" }
    its(:to) { should == "all-developers@example.com" }
    its(:subject) { should == "Great news for all developers!" }
    its(:raw_message) { should be_present }
  end

end
