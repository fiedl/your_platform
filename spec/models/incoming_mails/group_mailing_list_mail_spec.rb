require 'spec_helper'

describe IncomingMails::GroupMailingListMail do
  describe "#process" do
    subject { IncomingMails::GroupMailingListMail.from_message(example_raw_message).process }

    let(:example_raw_message) { %{
      From: john@example.com
      To: all-developers@example.com
      Subject: Great news for all developers!
      Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

      Free drinks this evening!
    }.gsub("  ", "") }

    let(:developers_group) {
      group = create :group, name: "Developers"
      group.mailing_lists.create label: "Mailing list", value: "all-developers@example.com"
      group
    }
    let(:john_doe) {
      create :user_with_account, email: 'john@example.com', locale: 'en'
    }

    before do
      ActionMailer::Base.deliveries = []
      @group = developers_group
      @user = john_doe
      @member = create :user_with_account, locale: 'en'
      @group << @member
    end

    shared_examples_for "nothing to do" do
      it 'does not send any email' do
        expect { subject }.not_to change { ActionMailer::Base.deliveries.count }
      end
      it 'does not create any post' do
        expect { subject }.not_to change { Post.count }
      end
      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end
      it { should == [] }
    end

    shared_examples_for "forwarding the message" do
      it 'forwards the email to the members with account' do
        expect { subject }.to change { ActionMailer::Base.deliveries.count }.by 1
        last_email.smtp_envelope_to.should == [@member.email]
        last_email.to.should == ['all-developers@example.com']
        last_email.from.should == ['john@example.com']
        last_email.subject.should include 'Great news for all developers!'
        last_email.body.should include 'Free drinks this evening!'
      end
      it 'does not create any post' do
        expect { subject }.not_to change { Post.count }
      end
      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end
    end

    describe "when the sender is unknown" do
      before { @user.destroy }
      it_behaves_like 'nothing to do'

      describe "when the mailing list is open" do
        before { @group.update! mailing_list_sender_filter: :open }
        it_behaves_like 'forwarding the message'
      end
    end
    describe "when the recipient is unknwon" do
      before { @group.destroy }
      it_behaves_like 'nothing to do'
    end
    describe "when sender and recipient group exist" do
      describe "when the sender is unauthorized" do
        it_behaves_like "nothing to do"
      end
      describe "when the sender is authorized" do
        before do
          @group.update! mailing_list_sender_filter: :open
        end
        it_behaves_like 'forwarding the message'
        describe "when the group has no members" do
          before { @member.destroy }
          it_behaves_like "nothing to do"
        end
      end
    end

    describe "when the body contains a utf-8-🍕" do
      let(:example_raw_message) { %{
        From: john@example.com
        To: all-developers@example.com
        Subject: Great news for all developers!
        Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

        Free drinks and 🍕 this evening!
      }.gsub("  ", "") }
      before do
        @group.update! mailing_list_sender_filter: :open
        @member = create :user_with_account, locale: 'en'
        @group << @member
      end
      it 'forwards the mail with 🍕' do
        subject
        last_email.body_in_utf8.should include '🍕'
      end
    end

    describe "when the body contains the {{greeting}} placeholder" do
      let(:example_raw_message) { %{
        From: john@example.com
        To: all-developers@example.com
        Subject: Great news for all developers!
        Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

        {{greeting}}!

        I have great news for you!
      }.gsub("  ", "") }
      before do
        @group.update! mailing_list_sender_filter: :open
      end
      it "replaces the {{greeting}} placeholder with the personal greeting for the recipient" do
        subject
        last_email.body.should include "Dear #{@member.name}!"
      end

      describe "when the message contains an attachment" do
        let(:example_raw_message) {
          message = Mail::Message.new %{
            From: john@example.com
            To: all-developers@example.com
            Subject: Great news for all developers!
            Message-ID: <579b28a0a60e2_5ccb3ff56d4319d8918bc@example.com>

            {{greeting}}!

            I have great news for you!
          }.gsub("  ", "")
          message.add_file File.expand_path(File.join(__FILE__, '../../../support/uploads/pdf-upload.pdf'))
          message
        }
        it "replaces the {{greeting}} placeholder with the personal greeting for the recipient" do
          subject
          last_email.to_s.should include "Dear #{@member.name}!"
          last_email.to_s.should_not include "{{greeting}}"
        end
      end
    end

  end
end

