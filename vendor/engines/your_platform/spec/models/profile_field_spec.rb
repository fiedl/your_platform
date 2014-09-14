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

  describe "#profileable" do
    describe "for un-structured or parent profile fields" do
      it "should return just the assigned profileable" do
        @user = create(:user)
        @profile_field = @user.profile_fields.create(label: "Address", type: "ProfileFieldTypes::Address")
        @profile_field.profileable.should == @user
      end
    end
    describe "for child profile fields" do
      it "should return the parent's profileable" do
        @user = create(:user)
        @profile_field = @user.profile_fields.create(label: "Bank Account", type: 'ProfileFieldTypes::BankAccount').becomes(ProfileFieldTypes::BankAccount)
        @profile_field.account_holder = "John Doe"
        @child_profile_field = @profile_field.children.first
        @child_profile_field.profileable.should == @user
      end
    end
  end

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
  before do
    @organization = ProfileFieldTypes::Organization.create()
  end

  subject { @organization }
  
  # Here it is only tested whether the methods exist. The functionality is
  # provided by the same mechanism as tested unter the BankAccount section.

  it { should respond_to( :to ) }
  it { should respond_to( :to= ) }
  it { should respond_to( :from ) }
  it { should respond_to( :from= ) }
  it { should respond_to( :role ) }
  it { should respond_to( :role= ) }

  describe "#cached(:children_count)" do
    subject { @organization.cached(:children_count) }
    it { should == 3 }
  end
end


# Email Contact Information
# ==========================================================================================

describe ProfileFieldTypes::Email do
  before do
    @email = ProfileFieldTypes::Email.create( label: "Email" )
  end

  describe "#children.count" do
    subject { @email.children.count }
    it { should == 0 }
  end

  describe "#cached(:children_count)" do
    subject { @email.cached(:children_count) }
    it { should == 0 }
  end

end


# Address Information
# ==========================================================================================

describe ProfileFieldTypes::Address do

  before do
    @address_field = ProfileFieldTypes::Address.new( label: "Address of the Brandenburg Gate",
                                                     value: "Pariser Platz 1\n 10117 Berlin" )
  end
  subject { @address_field }
  
  describe "#display_html" do
    subject { @address_field.display_html }
    it "should have a line-break in it" do
      subject.should include( "<br />" )
    end
  end

  describe "#geo_location" do
    subject { @address_field.geo_location }
    it { should be_kind_of GeoLocation }
  end

  describe "#find_geo_location" do
    subject { @address_field.find_geo_location }
    describe "before saving, before geocoding" do
      it { should == nil }
    end
    describe "after saving, before geocoding" do
      it { should == nil }
    end
    describe "before saving, after geocoding" do
      before { @address_field.geocode }
      it { should be_kind_of GeoLocation }
      its( :country_code ) { should == "DE" }
      its( :queried_at ) { should be_kind_of Time }
    end
    describe "after saving, after geocoding" do
      before { @address_field.save; @address_field.geocode }      
      it { should be_kind_of GeoLocation }
      its( :country_code ) { should == "DE" }
      its( :queried_at ) { should be_kind_of Time }
    end
  end

  describe "#find_or_create_geo_location" do
    subject { @address_field.find_or_create_geo_location }
    describe "even before explicit geocoding" do
      it { should be_kind_of GeoLocation }
    end
  end

  describe "#geocoded?" do
    subject { @address_field.geocoded? }
    describe "for a new address field" do
      it { should == false }
    end
    describe "after geocoding" do
      before { @address_field.geocode }
      it { should == true }
    end
    describe "after #find_or_create_geo_location" do
      before { @address_field.find_or_create_geo_location }
      it { should == true }
    end
    describe "after #find_geo_location" do
      before { @address_field.find_geo_location }
      it { should == false }
    end
    describe "after #geo_location" do
      before { @address_field.geo_location }
      it { should == true }
    end
  end

  describe "#geo_location" do
    subject { @address_field.geo_location }
    describe "for a new address field" do
      it "should perform a query" do
        @address_field.geocoded?.should == false
        subject
        @address_field.geocoded?.should == true
      end
    end
    describe "for an already geocoded address field" do
      before { @address_field.geocode }
      it "should not query again" do
        @queried_at = @address_field.geo_location.queried_at
        time_travel 2.seconds
        subject
        @address_field.geo_location.queried_at.should_not > @queried_at
      end
    end
  end

  describe "#geocode" do
    subject { @address_field.geocode }
    it "should perform a query" do
      @address_field.geocoded?.should == false
      subject
      @address_field.geocoded?.should == true
    end
  end

  its( :gmaps4rails_address ) { should == @address_field.value }

  describe "after saving" do
    before { @address_field.save }

    specify "latitude and longitude should be correct" do
      subject.latitude.round(4).should == 52.5163 
      subject.longitude.round(4).should == 13.3778
    end
    
    its( :country ) { should == "Germany" }
    its( :country_code ) { should == "DE" }
    its( :city ) { should == "Berlin" }
    its( :postal_code ) { should == "10117" }
    its( :plz ) { should == "10117" }
    
  end

  describe "postal address: " do
    before do
      @user = create(:user)
      @profile_field = @user.profile_fields.create(type: "ProfileFieldTypes::Address").becomes ProfileFieldTypes::Address
      @another_profile_field = @user.profile_fields.create(type: "ProfileFieldTypes::Address").becomes ProfileFieldTypes::Address
    end
    describe "#postal_address" do
      subject { @profile_field.postal_address }
      describe "for the address field being the primary postal address" do
        before { @profile_field.postal_address = true }
        it { should == true }
      end
      describe "for the address field not being the primary postal address" do
        before { @profile_field.postal_address = false }
        it { should == false }
      end
    end
    describe "#postal_address=" do
      describe "true" do
        subject { @profile_field.postal_address = true }
        it "should mark the profile field as postal address" do
          subject
          @profile_field.postal_address?.should == true
        end
        describe "for another address having been the primary postal address" do
          before { @another_profile_field.postal_address = true }
          it "should unmark the other address fields" do
            subject
            @another_profile_field.reload.postal_address?.should == false
          end
        end
      end
      describe "false" do
        subject { @profile_field.postal_address = false }
        describe "for the profile field being marked as primary postal address" do
          before { @profile_field.postal_address = true }
          it "should mark the profile field as no postal address" do
            subject
            @profile_field.reload.postal_address?.should == false
          end
        end
        it "should leave the other address fields alone" do
          expect { subject }.not_to change { @another_profile_field.postal_address? }
        end
      end
    end
    describe "#postal_address?" do
      subject { @profile_field.postal_address? }
      it "should be the same as #postal_address" do
        subject.should == @profile_field.postal_address
        @profile_field.postal_address = true
        @profile_field.reload.postal_address.should == true
        @profile_field.postal_address?.should == true
        @profile_field.postal_address = false
        @profile_field.reload.postal_address.should == false
        @profile_field.postal_address?.should == false
      end
    end
    describe "#clear_postal_address" do
      before { @another_profile_field.postal_address = true }
      subject { @profile_field.clear_postal_address }
      it "should remove all postal_address marks from this user's address fields" do
        subject
        @profile_field.reload.postal_address?.should == false
        @another_profile_field.reload.postal_address?.should == false
      end
    end
  end

end


# Employment Information
# ==========================================================================================

describe ProfileFieldTypes::Employment do
  before { @profile_field = ProfileFieldTypes::Employment.new }
  subject { @profile_field }

  it { should respond_to :from, :to, :organization, :position, :task }
  it { should respond_to :from=, :to=, :organization=, :position=, :task= }
  
  describe "#from" do
    subject { @profile_field.from }
    describe "before setting" do
      it { should == nil }
    end
    describe "after setting" do
      before { @profile_field.from = 6.years.ago }
      it { should be_kind_of Date }
    end
  end

  describe "#to" do
    subject { @profile_field.to }
    describe "before setting" do
      it { should == nil }
    end
    describe "after setting" do
      before { @profile_field.to = 6.years.ago }
      it { should be_kind_of Date }
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
        [ I18n.t( :account_holder ), I18n.t( :account_number ), I18n.t( :bank_code ), 
          I18n.t( :credit_institution ), I18n.t( :iban ), I18n.t( :bic ) ]
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

  describe "#cached(:children_count)" do
    subject { @bank_account.cached(:children_count) }
    it { should == 6 }
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


# Date Field
# ==========================================================================================

describe ProfileFieldTypes::Date do
  before { @date_field = ProfileFieldTypes::Date.create }
  describe "#value" do
    subject { @date_field.value }
    describe "if unset" do
      it { should == nil }
    end
    describe "if set to a date" do
      before { @date_field.value = 24.years.ago.to_date }
      it "should be a localized date String" do
        subject.should be_kind_of String
        subject.to_date.should == 24.years.ago.to_date
      end
    end
    describe "if set to a localized date string" do
      before { @date_field.value = I18n.localize(24.years.ago.to_date) }
      it "should be a localized date String" do
        subject.should be_kind_of String
        subject.to_date.should == 24.years.ago.to_date
      end
    end
  end
end
