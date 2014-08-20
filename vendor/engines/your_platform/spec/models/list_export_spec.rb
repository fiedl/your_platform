require 'spec_helper'

describe ListExport, :focus do
  
  before do
    @group = create :group
    @corporation = create :corporation
    @user = create :user
    @group.assign_user @user
    @corporation.assign_user @user  # in order to give the @user a #title other than his #name.
    @user_title_without_name = @user.title.gsub(@user.name, '').strip
  end
  
  describe "birthday_list: " do
    before do
      @user.date_of_birth = "1925-09-28".to_date
      @user.save
      @next_birthday = @user.date_of_birth.change(:year => Time.zone.now.year)
      
      @list_export = ListExport.new(@group.members, :birthday_list)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should == ['Nachname', 'Vorname', 'Namenszusatz', 'Diesjähriger Geburtstag', 'Geburtsdatum', 'Aktuelles Alter'] }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should == 
        "Nachname;Vorname;Namenszusatz;Diesjähriger Geburtstag;Geburtsdatum;Aktuelles Alter\n" +
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};#{I18n.localize(@next_birthday)};#{I18n.localize(@user.date_of_birth)};#{@user.age}\n"
      }
    end
  end
  
  describe "address_list: " do
    before do
      @address1 = @user.profile_fields.create(type: 'ProfileFieldTypes::Address', value: "Pariser Platz 1\n 10117 Berlin")
      @address1.update_attribute(:updated_at, "2014-06-20".to_datetime)
      @name_surrounding = @user.profile_fields.create(type: 'ProfileFieldTypes::NameSurrounding').becomes(ProfileFieldTypes::NameSurrounding)
      @name_surrounding.name_prefix = "Dr."
      @name_surrounding.name_suffix = "M.Sc."
      @name_surrounding.text_above_name = "Herrn"
      @name_surrounding.text_below_name = ""
      @name_surrounding.save
      @user.save
      
      @list_export = ListExport.new(@group.members, :address_list)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should == ['Nachname', 'Vorname', 'Namenszusatz', 'Postanschrift mit Name', 'Postanschrift', 
        'Letzte Änderung der Postanschrift am', 'Postleitzahl (PLZ)', 'Stadt', 'Land', 'Länder-Kennzeichen', 'Persönlicher Titel',
        'Zeile über dem Namen', 'Zeile unter dem Namen', 'Text vor dem Namen', 'Text hinter dem Namen']
      }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should == 
        "Nachname;Vorname;Namenszusatz;Postanschrift mit Name;Postanschrift;Letzte Änderung der Postanschrift am;Postleitzahl (PLZ);Stadt;Land;Länder-Kennzeichen;Persönlicher Titel;Zeile über dem Namen;Zeile unter dem Namen;Text vor dem Namen;Text hinter dem Namen\n" + 
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};\"Herrn\nDr. #{@user.name} M.Sc.\nPariser Platz 1\n10117 Berlin\";\"#{@user.postal_address}\";20.06.2014;10117;Berlin;Germany;DE;;Herrn;\"\";Dr.;M.Sc.\n"
      }
    end
  end
  
  describe "#phone_list: " do
    before do
      @phone_field = @user.profile_fields.create(label: 'Phone', type: 'ProfileFieldTypes::Phone', value: '123456').becomes(ProfileFieldTypes::Phone)
      @fax_field = @user.profile_fields.create(label: 'Fax', type: 'ProfileFieldTypes::Phone', value: '123457').becomes(ProfileFieldTypes::Phone)
      @mobile_field = @user.profile_fields.create(label: 'Mobile', type: 'ProfileFieldTypes::Phone', value: '01234').becomes(ProfileFieldTypes::Phone)
      @user.reload
      
      @list_export = ListExport.new(@group.members, :phone_list)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should == ['Nachname', 'Vorname', 'Namenszusatz', 'Beschriftung', 'Telefonnummer'] }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should ==
        "Nachname;Vorname;Namenszusatz;Beschriftung;Telefonnummer\n" + 
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Phone;123456\n" +
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Mobile;01234\n"
      }
    end
  end
  
  describe "name_list: " do
    before do
      @user.profile_fields.create(type: 'ProfileFieldTypes::AcademicDegree', value: "Dr. rer. nat.", label: :academic_degree)
      @user.profile_fields.create(type: 'ProfileFieldTypes::General', value: "Dr.", label: :personal_title)
      
      @list_export = ListExport.new(@group.members, :name_list)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should == ['Nachname', 'Vorname', 'Namenszusatz', 'Persönlicher Titel', 'Akademischer Grad'] }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should == 
        "Nachname;Vorname;Namenszusatz;Persönlicher Titel;Akademischer Grad\n" + 
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};Dr.;Dr. rer. nat.\n"
      }
    end
  end
end