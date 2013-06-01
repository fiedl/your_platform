require 'spec_helper'

describe Profileable do
  before do
    @profileable = create(:user)
    @profileable.profile_fields.create( type: "ProfileFieldTypes::Custom", label: "ICQ", value: "12345678" )
    @profileable.profile_fields.create( type: "ProfileFieldTypes::Phone", label: "Phone", value: "123-45678" )

    # create profile field with child fields
    bank_account = @profileable.profile_fields.create( type: "ProfileFieldTypes::BankAccount", label: "Account" )
      .becomes ProfileFieldTypes::BankAccount
    bank_account.account_holder = "John Doe"
    bank_account.save
  end

  describe "#profile_fields" do
    describe "#to_json" do
      subject { @profileable.profile_fields.to_json }
      it "should not raise an error" do
        expect { subject }.to_not raise_error
      end
    end
  end
end
