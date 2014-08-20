require 'spec_helper'

describe ListExport do
  
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
      it { should == ['Nachname', 'Vorname', 'Text hinter dem Namen', 'Diesjähriger Geburtstag', 'Geburtsdatum', 'Aktuelles Alter'] }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should == 
        "Nachname;Vorname;Text hinter dem Namen;Diesjähriger Geburtstag;Geburtsdatum;Aktuelles Alter\n" +
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};#{I18n.localize(@next_birthday)};#{I18n.localize(@user.date_of_birth)};#{@user.age}\n"
      }
    end
  end
end