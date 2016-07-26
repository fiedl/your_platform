require 'spec_helper'

describe ListExports::AddressList do

  before do
    @group = create :group
    @corporation = create :corporation_with_status_groups, name: "Monster, Inc."
    @user = create :user
    @group.assign_user @user
    @corporation.status_groups.first.assign_user @user  # in order to give the @user a #title other than his #name.
    @user_title_without_name = @user.title.gsub(@user.name, '').strip
    @user_title_without_name = '""' if @user_title_without_name.blank? # to match the csv format

    @address1 = @user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: "Pariser Platz 1\n 10117 Berlin")
    @address1.update_column(:updated_at, "2014-06-20".to_datetime)
    @name_surrounding = @user.profile_fields.create(type: 'ProfileFieldTypes::NameSurrounding').becomes(ProfileFieldTypes::NameSurrounding)
    @name_surrounding.name_prefix = "Dr."
    @name_surrounding.name_suffix = "M.Sc."
    @name_surrounding.text_above_name = "Herrn"
    @name_surrounding.text_below_name = ""
    @name_surrounding.save
    @user.save
  end

  let(:list_export) { ListExports::AddressList.from_group(@group) }
  subject { list_export }

  describe "#headers" do
    subject { list_export.headers }
    it { should include 'Nachname' }
    it { should include 'Vorname' }
    it { should include 'Namenszusatz' }
    it { should include 'Postanschrift mit Name' }
    it { should include 'Postanschrift' }
    it { should include 'Letzte Änderung der Postanschrift am' }
    it { should include 'Straße und Hausnummer' }
    it { should include 'Postleitzahl (PLZ)' }
    it { should include 'Stadt' }
    it { should include 'Bundesland' }
    it { should include 'Land' }
    it { should include 'Länder-Kennzeichen' }
    it { should include 'Länder-Kennzeichen (ISO 3166-1 alpha-3)' }
    it { should include 'Persönlicher Titel' }
    it { should include 'Persönlicher Titel und Name' }
    it { should include 'Zeile über dem Namen' }
    it { should include 'Zeile unter dem Namen' }
    it { should include 'Text vor dem Namen' }
    it { should include 'Text hinter dem Namen' }
  end
  describe "#to_csv" do
    subject { list_export.to_csv }
    it { should include 'Nachname' }
    it { should include 'Vorname' }
    it { should include 'Namenszusatz' }
    it { should include 'Postanschrift mit Name' }
    it { should include 'Postanschrift' }
    it { should include 'Letzte Änderung der Postanschrift am' }
    it { should include 'Straße und Hausnummer' }
    it { should include 'Postleitzahl (PLZ)' }
    it { should include 'Stadt' }
    it { should include 'Bundesland' }
    it { should include 'Land' }
    it { should include 'Länder-Kennzeichen' }
    it { should include 'Länder-Kennzeichen (ISO 3166-1 alpha-3)' }
    it { should include 'Persönlicher Titel' }
    it { should include 'Persönlicher Titel und Name' }
    it { should include 'Zeile über dem Namen' }
    it { should include 'Zeile unter dem Namen' }
    it { should include 'Text vor dem Namen' }
    it { should include 'Text hinter dem Namen' }
    it { should include @user.last_name }
    it { should include @user.first_name }
    it { should include @user_title_without_name }
    it { should include "\"Herrn\nDr. #{@user.name} M.Sc.\n#{@corporation.name}\nPariser Platz 1\n10117 Berlin\"" }
    it { should include "\"#{@user.postal_address}\"" }
    it { should include "20.06.2014" }
    it { should include "Pariser Platz 1" }
    it { should include "10117" }
    it { should include "Berlin" }
    it { should include "DE" }
    it { should include "DEU" }
    it { should include "Herrn" }
    it { should include "Dr." }
    it { should include "M.Sc." }
    it { should include "Dr. #{@user.name}" }
  end

end