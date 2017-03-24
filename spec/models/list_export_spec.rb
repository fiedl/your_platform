require 'spec_helper'

describe ListExport do

  before do
    @group = create :group
    @corporation = create :corporation_with_status_groups
    @user = create :user
    @group.assign_user @user
    @corporation.status_groups.first.assign_user @user  # in order to give the @user a #title other than his #name.
    @user_title_without_name = @user.title.gsub(@user.name, '').strip
    @user_title_without_name = '""' if @user_title_without_name.blank? # to match the csv format
  end

  describe "#phone_list: " do
    before do
      @phone_field = @user.profile_fields.create(label: 'Phone', type: 'ProfileFields::Phone', value: '123456').becomes(ProfileFields::Phone)
      @fax_field = @user.profile_fields.create(label: 'Fax', type: 'ProfileFields::Phone', value: '123457').becomes(ProfileFields::Phone)
      @mobile_field = @user.profile_fields.create(label: 'Mobile', type: 'ProfileFields::Phone', value: '01234').becomes(ProfileFields::Phone)
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

  describe "member_development: " do
    before do
      @user.direct_memberships.destroy_all
      @corporation = create :corporation_with_status_groups
      @status_group_names = @corporation.status_groups.collect { |group| group.name }
      @date1 = "2006-12-01".to_datetime
      @date2 = "2007-02-02".to_datetime
      @date3 = "2008-04-01".to_datetime
      @membership1 = @corporation.status_groups[0].assign_user @user, at: @date1
      @membership2 = @membership1.move_to @corporation.status_groups[1], at: @date2
      @membership3 = @membership2.move_to @corporation.status_groups[2], at: @date3
      @user.reload
      @user_title_without_name = @user.title.gsub(@user.name, '').strip
      @user_title_without_name = '""' if @user_title_without_name.blank? # to match the csv format

      @list_export = ListExport.new(@corporation, :member_development)
    end
    describe "#headers" do
      subject { @list_export.headers }
      it { should include 'Nachname', 'Vorname', 'Namenszusatz', 'Geburtsdatum', 'Verstorben am', *@status_group_names }
    end
    describe "#to_csv" do
      subject { @list_export.to_csv }
      it { should ==
        "Nachname;Vorname;Namenszusatz;Geburtsdatum;Verstorben am;Member Status 1;Member Status 2;Member Status 3\n" +
        "#{@user.last_name};#{@user.first_name};#{@user_title_without_name};;;01.12.2006;02.02.2007;01.04.2008\n"
      }
    end
  end

end