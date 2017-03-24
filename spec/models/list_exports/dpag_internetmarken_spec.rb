require 'spec_helper'

describe ListExports::DpagInternetmarken do
  
  before do
    @group = create :group
    @user = create :user, :with_address, first_name: "Jonathan", last_name: "Doe"
    @user.address_profile_fields.first.update_attributes value: "Pariser Platz 1\n 10117 Berlin"
    @user.profile_fields.create label: 'personal_title', value: "Dr."
    @name_surrounding = @user.profile_fields.create type: "ProfileFields::NameSurrounding"
    @name_surrounding = @user.profile_fields.where(type: "ProfileFields::NameSurrounding").first
    @name_surrounding.text_below_name = "c./o. Foo Bar"
    @name_surrounding.save
    @group << @user
    @list_export = ListExports::DpagInternetmarken.from_group(@group)
  end
  
  describe "#headers" do
    subject { @list_export.headers }
    it "should correspond to the correct headers required by the dpag webapp" do
      subject.join(";").should == "NAME;ZUSATZ;STRASSE;NUMMER;PLZ;STADT;LAND;ADRESS_TYP"
    end
  end
  
  describe "#to_csv" do
    subject { @list_export.to_csv }
    it { should == 
      "NAME;ZUSATZ;STRASSE;NUMMER;PLZ;STADT;LAND;ADRESS_TYP\n" +
      "Bitte eintragen: Absender-Name;;Absender-Straße;Absender-Hausnummer;Absender-PLZ;Absender-Stadt;DEU;HOUSE\n" +
      "Dr. Jonathan Doe;c./o. Foo Bar;Pariser Platz;1;10117;Berlin;DEU;HOUSE\n"
    }
  end
  
end