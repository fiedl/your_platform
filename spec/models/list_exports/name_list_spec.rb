require 'spec_helper'

describe ListExports::NameList do
  
  before do
    @group = create :group, name: 'MyGroup'
    @user = create :user, :with_address, first_name: "Jonathan", last_name: "Doe"
    @user.address_profile_fields.first.update_attributes value: "Pariser Platz 1\n 10117 Berlin"
    @user.profile_fields.create label: 'personal_title', value: "Dr."
    @name_surrounding = @user.profile_fields.create type: "ProfileFieldTypes::NameSurrounding"
    @name_surrounding = @user.profile_fields.where(type: "ProfileFieldTypes::NameSurrounding").first
    @name_surrounding.text_below_name = "c./o. Foo Bar"
    @name_surrounding.save
    @user.profile_fields.create(type: 'ProfileFieldTypes::AcademicDegree', value: "Dr. rer. nat.", label: :academic_degree)
    @user.profile_fields.create(type: 'ProfileFieldTypes::General', value: "Dr.", label: :personal_title)
    @user_title_without_name = @user.title.gsub(@user.name, '').strip
    @user_title_without_name = '""' if @user_title_without_name.blank? # to match the csv format
    @group << @user

    @list_export = ListExports::NameList.from_group(@group)
  end

  describe "#headers" do
    subject { @list_export.headers }
    it { should include 'Nachname', 'Vorname', 'Namenszusatz', 'Persönlicher Titel', 'Akademischer Grad', "Mitglied in 'MyGroup' seit" }
  end

  describe "#to_csv" do
    subject { @list_export.to_csv }
    it { should include "Nachname;Vorname;Namenszusatz;Persönlicher Titel;Akademischer Grad;Mitglied in 'MyGroup' seit" }
    it { should include "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Dr.;Dr. rer. nat.;#{I18n.l(Date.today)}" }
  end
  
end