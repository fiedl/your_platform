require 'spec_helper'

describe Mail::Message do
  describe "#deliver" do
    subject { @message.deliver_now } # will call `deliver` internally

    describe "when using the delivery-filter feature" do
      before do
        require_relative '../../../app/models/ability'
        class Ability
          def rights_for_everyone
            can :use, :mail_delivery_account_filter # Feature Switch
          end
        end
      end

      describe "for users without account" do
        before do
          @user = create :user, email: 'john@example.com'
          @random_string = ('a'..'z').to_a.shuffle[0,8].join
          @message = UserAccountMailer.welcome_email(@user, "Test: #{@random_string}")
        end

        it { should == false }
        it "should not send a message" do
          last_email.to_s.should_not include @random_string
        end
      end
    end

    describe "(spam-protection conformity)" do
      # https://trello.com/c/s94OXzul, https://stackoverflow.com/q/57173606/2066546

      describe "when the from field has the form 'foo@example.com'" do
        subject { Mail::Message.new(from: "foo@example.com", to: "\"Bar\" <bar@example.com>", subject: "Test", body: "Test").deliver }
        it "should raise an error to ensure anti-spam conformity." do
          expect { subject }.to raise_error(/Make sure the from field .*/)
        end
      end

      describe "when the from field has the correct form" do
        subject { Mail::Message.new(from: "\"Foo\" <foo@example.com>", to: "\"Bar\" <bar@example.com>", subject: "Test", body: "Test").deliver }
        it "should not raise an error to ensure anti-spam conformity." do
          expect { subject }.not_to raise_error(/Make sure the from field .*/)
        end
      end

      describe "when the to field has the form 'bar@example.com'" do
        subject { Mail::Message.new(from: "\"Foo\" <foo@example.com>", to: "bar@example.com", subject: "Test", body: "Test").deliver }
        it "should raise an error to ensure anti-spam conformity." do
          expect { subject }.to raise_error(/Make sure the to field .*/)
        end
      end

      describe "when the to field has the correct form" do
        subject { Mail::Message.new(from: "\"Foo\" <foo@example.com>", to: "\"Bar\" <bar@example.com>", subject: "Test", body: "Test").deliver }
        it "should not raise an error to ensure anti-spam conformity." do
          expect { subject }.not_to raise_error(/Make sure the to field .*/)
        end
      end

      describe "when the to field has several recipients in the correct form" do
        subject { Mail::Message.new(from: "\"Foo\" <foo@example.com>", to: "\"Bar\" <bar@example.com>, \"Baz\" <baz@example.com>", subject: "Test", body: "Test").deliver }
        it "should not raise an error to ensure anti-spam conformity." do
          expect { subject }.not_to raise_error(/Make sure the to field .*/)
        end
      end

      describe "when the tol field has several recipients, but one in the wrong form" do
        subject { Mail::Message.new(from: "\"Foo\" <foo@example.com>", to: "\"Bar\" <bar@example.com>, baz@example.com", subject: "Test", body: "Test").deliver }
        it "should raise an error to ensure anti-spam conformity." do
          expect { subject }.to raise_error(/Make sure the to field .*/)
        end
      end

    end
  end
end