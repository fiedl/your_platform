require 'spec_helper'

describe IncomingMails::BounceMail do
  let(:example_raw_message) { File.read('spec/support/emails/undelivered.eml') }
  let(:bounced_mail) { IncomingMails::BounceMail.create_from_message(example_raw_message) }
  let(:john_doe) { create :user_with_account, email: 'info@example.com' }
  let(:original_delivery) { Delivery.create message_id: '7CC0C1AD-99D4-4E5F-BC17-40532074446D@example.com',
    user_email: 'info@example.com',
    user_id: john_doe.id
  }

  describe "#bounced?" do
    subject { bounced_mail.bounced? }
    it { should be_true }
  end

  describe "#rejected_message_id" do
    subject { bounced_mail.rejected_message_id}
    it { should == '7CC0C1AD-99D4-4E5F-BC17-40532074446D@example.com' }
  end

  describe "#rejected_recipient_email" do
    subject { bounced_mail.rejected_recipient_email }
    it { should == 'info@example.com' }
  end

  describe "#rejected_delivery" do
    subject { bounced_mail.rejected_delivery }
    before { john_doe; original_delivery }
    it { should == original_delivery }
  end

  describe "#process" do
    subject { bounced_mail.process }
    before { john_doe; original_delivery }

    it 'marks the delivery as failed' do
      subject
      original_delivery.reload.failed_at.should be_present
    end



  end
end
