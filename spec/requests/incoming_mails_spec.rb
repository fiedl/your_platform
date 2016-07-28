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
    } }

    describe "/incoming_mails" do
      subject {
        post '/incoming_mails', {
          message: example_raw_message
        }
        response
      }

      it { should be_success }

      it 'returns the created objects as json array' do
        subject
        json_response = JSON.parse response.body
        json_response.should be_kind_of? Array
        json_response.count.should == 1
      end
    end

    describe "/incoming_emails" do
      subject { post '/incoming_emails', {message: example_raw_message} }
      it { should be_success }
    end
  end
end


