require 'spec_helper'

# General Profile Field
# ==========================================================================================

describe ProfileField do

  subject { ProfileField.new }

  describe "accessible attributes" do
    [ :label, :type, :value ].each do |attr|
      it { should respond_to( attr ) }
      it { should respond_to( "#{attr}=".to_sym ) }
    end
  end

  it { should respond_to( :profileable ) }

  describe "acts_as_tree" do
    it { should respond_to( :parent ) }
    it { should respond_to( :children ) }
  end

  it { should respond_to( :display_html ) }

end


# Custom Contact Information
# ==========================================================================================

describe ProfileFieldTypes::Custom do
  describe ".create" do
    subject { ProfileFieldTypes::Custom.create( label: "Custom Contact Information" ) }
    its( 'children.count' ) { should == 0 }
  end
end


# Organisation Membership Information
# ==========================================================================================

describe ProfileFieldTypes::Organization do
  subject { ProfileFieldTypes::Organization.create() }
  
  # Here it is only tested whether the methods exist. The functionality is
  # provided by the same mechanism as tested unter the BankAccount section.

  it { should respond_to( :organization ) }
  it { should respond_to( :organization= ) }
  it { should respond_to( :role ) }
  it { should respond_to( :role= ) }
  it { should respond_to( :since_when ) }
  it { should respond_to( :since_when= ) }
end


# Email Contact Information
# ==========================================================================================

describe ProfileFieldTypes::Email do
  describe ".create" do
    subject { ProfileFieldTypes::Email.create( label: "Email" ) }
    its( 'children.count' ) { should == 0 }
  end
end


# Address Information
# ==========================================================================================

describe ProfileFieldTypes::Address do

  before do
    # use a global variable ($...) to make sure the profile_field objects is only created
    # once. Otherwise, this series of tests will hit the traffic limitation of the 
    # geodata service of google.
    $address_field ||= ProfileFieldTypes::Address.create( label: "Address of the Brandenburg Gate",
                                                          value: "Pariser Platz 1\n 10117 Berlin" )
    @address_field = $address_field
  end
  subject { @address_field }
  
  specify "latitude and longitude should be correct" do
    subject.latitude.round(4).should == 52.5163 
    subject.longitude.round(4).should == 13.3777
  end

  its( :country ) { should == "Germany" }
  its( :country_code ) { should == "DE" }
  its( :city ) { should == "Berlin" }
  its( :postal_code ) { should == "10117" }
  its( :plz ) { should == "10117" }

  # This is needed in order to display the map later.
  its( :gmaps4rails_address ) { should == @address_field.value }

  describe "#display_html" do
    subject { @address_field.display_html }
    it "should have a line-break in it" do
      subject.should include( "<br />" )
    end
  end

end


# Bank Account Information
# ==========================================================================================

describe ProfileFieldTypes::BankAccount do

  before do
    @bank_account = ProfileFieldTypes::BankAccount.create( label: "Bank Account" )
  end
  subject { @bank_account }

  describe ".create" do
    subject { ProfileFieldTypes::BankAccount.create( label: "Bank Account" ) }

    it "should create 6 children" do
      subject.children.count.should == 6
    end
    it "should create the correct labels for the children" do
      subject.children.collect { |child| child.label }.should ==
        [ "Account Holder", "Account Number", "Bank Code", 
          "Credit Institution", "IBAN", "BIC" ]
    end

  end

  describe "#account_holder" do
    before do
      @account_holder = "John Doe"
      @bank_account.account_holder = @account_holder
    end
    subject { @bank_account.account_holder }
    it { should == @account_holder }
  end

  describe "#account_holder=" do
    before do
      @new_account_holder = "Johnny Doe"
    end
    it "should set the account holder" do
      @bank_account.account_holder = @new_account_holder
      @bank_account.account_holder.should == @new_account_holder
    end
  end

  describe "other child profile field accessors" do
    before { @profile_field = @bank_account }
    [ :account_holder, :account_number, :bank_code,
      :credit_institution, :iban, :bic ].each do |attr|
      describe "getter method" do
        before do
          @value = "This is a value"
          @profile_field.send( "#{attr}=".to_sym, @value )
        end
        subject { @profile_field.send( attr ) }
        it { should == @value }
      end
      describe "setter method" do
        before { @new_value = "New Value" }
        it "should set the value" do
          @profile_field.send( "#{attr}=".to_sym, @new_value )
          @profile_field.send( attr ).should == @new_value
        end
      end
    end
  end

end  

# Description Field
# ==========================================================================================

describe ProfileFieldTypes::Description do
  before { @description_field = ProfileFieldTypes::Description.create( label: "Heraldic Animal", 
                                                                       value: "The heraldic animal of the organisation is a fox." ) }
  subject { @description_field }
  its( :display_html ) { should include( @description_field.value ) }
end


# Phone Number Field
# ==========================================================================================

describe ProfileFieldTypes::Phone do
  
  describe "international number with leading 00" do
    subject { ProfileFieldTypes::Phone.create( value: "0049800123456789" ) }
    its( :value ) { should == "+49 800 123 456789" } # on the basis of E164
  end
  
  describe "international number with leading +" do
    subject { ProfileFieldTypes::Phone.create( value: "+49 800 123456789" ) }
    its( :value ) { should == "+49 800 123 456789" } # on the basis of E164
  end
  
  describe "national number" do
    subject { ProfileFieldTypes::Phone.create( value: "0800123456789" ) }
    it "should not be formatted, since the country is not unique" do
      subject.value.should == "0800123456789"
    end
  end
  
end


# Homepage Field
# ==========================================================================================

describe ProfileFieldTypes::Homepage do

  subject { ProfileFieldTypes::Homepage.create( value: "example.com" ) }

  its( :display_html ) { should == "<a href=\"http://example.com\">http://example.com</a>" }

end


