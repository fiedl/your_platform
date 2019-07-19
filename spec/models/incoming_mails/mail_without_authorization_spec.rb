require 'spec_helper'

describe IncomingMails::MailWithoutAuthorization do
  describe "#process" do
    subject { IncomingMails::MailWithoutAuthorization.from_message(example_raw_message).process }

    let(:example_raw_message) { %{
      From: john@example.com
      To: all-developers@example.com
      Subject: Great news for all developers!
      Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

      Free drinks this evening!
    }.gsub("  ", "") }

    let(:developers_group) {
      group = create :group, name: "Developers", mailing_list_sender_filter: :users_with_account
      group.mailing_lists.create label: "Mailing list", value: "all-developers@example.com"
      group
    }
    let(:john_doe) {
      create :user_with_account, email: 'john@example.com'
    }

    before do
      ActionMailer::Base.deliveries = []
      @group = developers_group
    end

    it { should be_kind_of Array }

    describe "when the sender is in the database" do
      describe "when the user has an account" do
        before { @user = john_doe }
        it 'sends no rejection mail' do
          subject
          ActionMailer::Base.deliveries.count.should == 0
        end
        its(:count) { should == 0 }
        describe "when the sender is unauthorized" do
          before { @group.update! mailing_list_sender_filter: :global_officers }
          it 'sends a rejection mail' do
            subject
            last_email.to.should == ["john@example.com"]
            last_email.body.decoded.should include I18n.t(:you_are_unauthorized_to_send_to_this_mailing_list)
          end
        end
      end
      describe "when the user has no account" do
        before { @user = john_doe; @user.account.destroy; @user.reload }
        it 'sends a rejection mail' do
          subject
          last_email.to.should == ["john@example.com"]
          last_email.body.decoded.should include I18n.t(:your_account_is_inactive_please_reply)
        end
      end
    end

    describe "when the sender is not in the database" do
      describe "when the mailing list is closed" do
        before { @group.update! mailing_list_sender_filter: :group_members }

        its(:count) { should == 1 }
        it 'sends a rejection mail' do
          subject
          last_email.to.should == ["john@example.com"]
          last_email.body.decoded.should include I18n.t(:we_could_not_determine_who_you_are)
          last_email.body.decoded.should include I18n.t(:if_you_need_help_reply_to_contact_our_support_team)
        end
      end
      describe "when the mailing list is open" do
        before { @group.update! mailing_list_sender_filter: :open }
        it 'sends no rejection mail' do
          subject
          ActionMailer::Base.deliveries.count.should == 0
        end
      end
    end
  end
end