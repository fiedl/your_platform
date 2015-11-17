require 'spec_helper'

describe ListExports::BirthdayList do
  
  before do
    @group = create :group
    @user = create :user, :with_address, first_name: "Jonathan", last_name: "Doe"
    @user.address_profile_fields.first.update_attributes value: "Pariser Platz 1\n 10117 Berlin"
    @user.profile_fields.create label: 'personal_title', value: "Dr."
    @name_surrounding = @user.profile_fields.create type: "ProfileFieldTypes::NameSurrounding"
    @name_surrounding = @user.profile_fields.where(type: "ProfileFieldTypes::NameSurrounding").first
    @name_surrounding.text_below_name = "c./o. Foo Bar"
    @name_surrounding.save
    @user.localized_date_of_birth = "13.11.1986"; @user.save
    @group << @user

    @list_export = ListExports::BirthdayList.from_group(@group)
  end
  
  describe "#headers" do
    subject { @list_export.headers }
    specify { subject.join(";").should == "Nachname;Vorname;Namenszusatz;Diesjähriger Geburtstag;Geburtsdatum;Aktuelles Alter" }
  end
  
  describe "#to_csv" do
    subject { @list_export.to_csv }
    it { Timecop.travel "2015-08-20".to_datetime { should == 
      "Nachname;Vorname;Namenszusatz;Diesjähriger Geburtstag;Geburtsdatum;Aktuelles Alter\n" +
      "Doe;Jonathan;\"\";13.11.2015;13.11.1986;28\n" }
    }
  end
  
end