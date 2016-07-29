require 'spec_helper'

describe IncomingMails::MailWithUnknownSender do
  describe "#process" do
    subject { IncomingMails::MailWithUnknownSender.create_from_message(example_raw_message).process }
    let(:example_raw_message) { %{
      From: john@example.com
      To: all-developers@example.com
      Subject: Great news for all developers!
      Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

      Free drinks this evening!
    }.gsub("  ", "") }
    before { ActionMailer::Base.deliveries = [] }

    it { should be_kind_of Array }

    describe "when the sender is in the database" do
      before { @user = create :user_with_account, email: 'john@example.com' }
      it 'sends no rejection mail' do
        subject
        ActionMailer::Base.deliveries.count.should == 0
      end
      its(:count) { should == 0 }
    end

    describe "when the sender is not in the database" do
      its(:count) { should == 1 }
      it 'sends a rejection mail' do
        subject
        last_email.to.should == ["john@example.com"]
        last_email.body.decoded.should include I18n.t(:we_could_not_determine_who_you_are)
        last_email.body.decoded.should include I18n.t(:if_you_need_help_reply_to_contact_our_support_team)
      end
    end
  end
end