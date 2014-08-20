require 'spec_helper'

describe GroupMixins::Csv do
  before do
    @group = create :group
    @corporation = create :corporation
    @user = create :user
    @group.assign_user @user
    @corporation.assign_user @user  # in order to give the @user a #title other than his #name.
    @user_title_without_name = @user.title.gsub(@user.name, '').strip
  end
  
  describe "#members_phone_numbers_to_csv" do
    subject { @group.members_phone_numbers_to_csv }
    before do
      @phone_field = @user.profile_fields.create(label: 'Phone', type: 'ProfileFieldTypes::Phone', value: '123456').becomes(ProfileFieldTypes::Phone)
      @fax_field = @user.profile_fields.create(label: 'Fax', type: 'ProfileFieldTypes::Phone', value: '123457').becomes(ProfileFieldTypes::Phone)
      @mobile_field = @user.profile_fields.create(label: 'Mobile', type: 'ProfileFieldTypes::Phone', value: '01234').becomes(ProfileFieldTypes::Phone)
      @user.reload
    end
    it { should ==
      "Nachname;Vorname;\"\";Beschriftung;Telefonnummer\n" + 
      "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Phone;123456\n" +
      "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Mobile;01234\n"
    }
  end
  describe "#members_emails_to_csv" do
    subject { @group.members_emails_to_csv }
    before do
      @user.profile_fields.where(type: 'ProfileFieldTypes::Email').each { |field| field.destroy }
      @email_field_1 = @user.profile_fields.create(label: 'Email', type: 'ProfileFieldTypes::Email', value: 'foo@example.com').becomes(ProfileFieldTypes::Email)
      @email_field_2 = @user.profile_fields.create(label: 'Work Email', type: 'ProfileFieldTypes::Email', value: 'bar@example.com').becomes(ProfileFieldTypes::Email)
      @user.reload
    end
    it { should ==
      "Nachname;Vorname;\"\";Beschriftung;E-Mail-Adresse\n" + 
      "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Email;foo@example.com\n" +
      "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Work Email;bar@example.com\n"
    }
  end
end