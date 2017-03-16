require 'spec_helper'

describe ListExports::EmailList do

  before do
    @group = create :group
    @user = create :user, :with_address, first_name: "Jonathan", last_name: "Doe"
    @user.address_profile_fields.first.update_attributes value: "Pariser Platz 1\n 10117 Berlin"
    @user.profile_fields.create label: 'personal_title', value: "Dr."
    @name_surrounding = @user.profile_fields.create type: "ProfileFields::NameSurrounding"
    @name_surrounding = @user.profile_fields.where(type: "ProfileFields::NameSurrounding").first
    @name_surrounding.text_below_name = "c./o. Foo Bar"
    @name_surrounding.save
    @user.localized_date_of_birth = "13.11.1986"; @user.save
    @group << @user

    @user.profile_fields.where(type: 'ProfileFields::Email').each { |field| field.destroy }
    @email_field_1 = @user.profile_fields.create(label: 'Email', type: 'ProfileFields::Email', value: 'foo@example.com').becomes(ProfileFields::Email)
    @email_field_2 = @user.profile_fields.create(label: 'Work Email', type: 'ProfileFields::Email', value: 'bar@example.com').becomes(ProfileFields::Email)
    @user.reload

    @list_export = ListExports::EmailList.from_group(@group)
  end

  describe "#headers" do
    subject { @list_export.headers }
    it { should include 'Nachname', 'Vorname', 'Namenszusatz', 'Beschriftung', 'E-Mail-Adresse', 'Mitglied seit' }
  end

  describe "#to_csv" do
    subject { @list_export.to_csv }
    it { should ==
      "Nachname;Vorname;Namenszusatz;Beschriftung;E-Mail-Adresse;Mitglied seit\n" +
      "#{@user.last_name};#{@user.first_name};\"\";Email;foo@example.com;#{I18n.l(Date.today)}\n" +
      "#{@user.last_name};#{@user.first_name};\"\";Work Email;bar@example.com;#{I18n.l(Date.today)}\n"
    }
  end

end
