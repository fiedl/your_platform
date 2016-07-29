require 'spec_helper'

# Have a look at: http://matthewlehner.net/rails-api-testing-guidelines/
#
describe "Incoming mails" do
  describe "POST" do

    let(:example_raw_message) { %{
      From: john@example.com
      To: all-developers@example.com
      Subject: Great news for all developers!

      Free drinks this evening!
    }.gsub("      ", "") }

    describe "/incoming_mails" do
      subject {
        post '/incoming_mails', {
          message: example_raw_message
        }
        response
      }

      it { should_not be_unauthorized }
      it { should be_success } # "201 created"

      it 'returns the created incoming_mail' do
        subject
        json_response = JSON.parse response.body
        json_response.should be_kind_of Hash
        json_response['id'].should == IncomingMail.last.id
      end
    end

    describe "/incoming_emails" do
      subject { post '/incoming_emails', {message: example_raw_message}; response }
      it { should be_success }
    end
  end
end


