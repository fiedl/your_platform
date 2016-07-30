require 'spec_helper'

describe IncomingMails::GroupMailingListMail do
  describe "#process" do
    subject { IncomingMails::GroupMailingListMail.create_from_message(example_raw_message).process }

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
      create :user_with_account, email: 'john@example.com'
    }

    before { ActionMailer::Base.deliveries = [] }

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

    describe "when the sender is unknown" do
      before { @group = developers_group }
      it_behaves_like 'nothing to do'
    end
    describe "when the recipient is unknwon" do
      before { @user = john_doe }
      it_behaves_like 'nothing to do'
    end
    describe "when sender and recipient group exist" do
      before do
        @group = developers_group
        @user = john_doe
      end
      describe "when the sender is unauthorized" do
        it_behaves_like "nothing to do"
      end
      describe "when the sender is authorized" do
        before do
          @group.update! mailing_list_sender_filter: :open
          @member = create :user_with_account
          @group << @member
        end

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
        it { should == [ one_delivery_here ] }

        describe "when the group has no members" do
          before { @member.destroy }
          it_behaves_like "nothing to do"
        end
      end
    end

  end
end

