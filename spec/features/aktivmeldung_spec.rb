require 'spec_helper'

feature "Aktivmeldung" do
  include SessionSteps

  before do
    @corporation = create(:corporation)
    @aktivitas_group = @corporation.child_groups.create(name: "Aktivitas")
    @intranet_root = Page.create(title: "Intranet Root").add_flag(:intranet_root)

    login(:admin)
  end
  
  specify "make sure the prelims are fulfilled" do
    @corporation.descendant_groups.collect { |group| group.title }.should include "Hospitanten"
  end

  specify "click 'Aktivmeldung' and add a new user" do
    
    visit root_path
    click_on "Aktivmeldung eintragen"

    page.should have_content "Aktivmeldung eintragen"
    fill_in I18n.t(:first_name), with: "Bundesbruder"
    fill_in I18n.t(:last_name), with: "Kanne"
    fill_in I18n.t(:email), with: "bbr.kanne@example.com"
    select @corporation.title, from: I18n.t(:register_in)
    check I18n.t(:create_account)

    page.find("input[name='commit']").click

    page.should have_content "Bundesbruder Kanne"
    page.should have_content I18n.t(:date_of_birth)

    page.should have_content I18n.t(:personal_title)
    page.should have_content I18n.t(:academic_degree)
    page.should have_content I18n.t(:cognomen)
    page.should have_content I18n.t(:klammerung)

    page.should have_content I18n.t(:email)

    page.should have_content I18n.t(:home_address)
    page.should have_content I18n.t(:work_or_study_address)
    page.should have_content I18n.t(:phone)
    page.should have_content I18n.t(:mobile)
    page.should have_content I18n.t(:fax)
    page.should have_content I18n.t(:homepage)

    page.should have_content I18n.t(:study)

    page.should have_content I18n.t(:professional_category)
    page.should have_content I18n.t(:occupational_area)
    page.should have_content I18n.t(:employment_status)
    page.should have_content I18n.t(:languages)

    page.should have_content I18n.t(:bank_account)

    page.should have_content I18n.t(:name_field_wingolfspost)
    page.should have_content I18n.t(:wbl_abo)

  end

end
