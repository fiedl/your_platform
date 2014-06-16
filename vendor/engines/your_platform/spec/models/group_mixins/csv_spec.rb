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
  
  describe "#members_names_to_csv" do
    subject { @group.members_names_to_csv }
    before do
      @user.profile_fields.create(type: 'ProfileFieldTypes::AcademicDegree', value: "Dr. rer. nat.", label: :academic_degree)
      @user.profile_fields.create(type: 'ProfileFieldTypes::General', value: "Dr.", label: :personal_title)
    end
    it { should == 
      "Nachname;Vorname;\"\";\"\";Persönlicher Titel;Akademischer Grad\n" + 
      "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};#{@user.title};Dr.;Dr. rer. nat.\n"
    }
  end
  describe "#members_birthdays_to_csv" do
    subject { @group.members_birthdays_to_csv }
    before do
      @user.date_of_birth = "1925-09-28".to_date
      @next_birthday = @user.date_of_birth.change(:year => Time.zone.now.year)
    end
    specify "prelims" do
      @user.date_of_birth.should_not be_nil
      @user.localized_date_of_birth.should == I18n.localize("1925-09-28".to_date)
    end
    it { should ==
      "Nachname;Vorname;\"\";Geburtstag;Geburtsdatum;Aktuelles Alter\n" +
      "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};#{I18n.localize(@next_birthday)};#{I18n.localize(@user.date_of_birth)};#{@user.age}\n"
    }
  end
  describe "#members_addresses_to_csv" do
    pending
  end
end