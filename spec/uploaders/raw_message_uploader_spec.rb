require 'spec_helper'
require 'carrierwave/test/matchers'

describe RawMessageUploader do
  include CarrierWave::Test::Matchers

  let(:example_raw_message) { %{
    From: john@example.com
    To: all-developers@example.com
    Subject: Great news for all developers!

    Free drinks this evening!
  }.gsub("      ", "") }

  before { RawMessageUploader.enable_processing = true }
  after { RawMessageUploader.enable_processing = false }
  after { @uploader.remove! }

  before do
    @incoming_mail = IncomingMail.create!
    @uploader = RawMessageUploader.new(@incoming_mail)
  end

  describe "#store!" do
    describe "given a raw message string" do
      subject { @uploader.store! example_raw_message }
      it 'should store the file' do
        subject
        File.file?(@uploader.path).should be_true
      end
    end

    describe "given a Mail::Message" do
      subject { @uploader.store! Mail::Message.new(example_raw_message) }
      it 'should store the file' do
        subject
        File.file?(@uploader.path).should be_true
      end
    end
  end
end