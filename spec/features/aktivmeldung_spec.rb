require 'spec_helper'

feature "Aktivmeldung" do
  include SessionSteps

  before do
    @my_corporations = [create(:wingolf_corporation), create(:wingolf_corporation)]
    @corporation = @my_corporations.first
    @other_corporation = create(:wingolf_corporation)
    @aktivitas_group = @corporation.aktivitas
    @intranet_root = Page.intranet_root
    @corporation.reload
    
    @local_admin_user = create :user_with_account
    @aktivitas_group.admins << @local_admin_user
    @my_corporations.last.admins << @local_admin_user
    time_travel 2.seconds
  end
  
  specify "make sure the prelims are fulfilled" do
    @corporation.descendant_groups.map(&:title).should include "Hospitanten"
    @local_admin_user.administrated_aktivitates.collect(&:corporation).should == @my_corporations
  end

  scenario "click 'Aktivmeldung' and add a new user" do
    login @local_admin_user
        
    visit root_path
    within('.aktivmeldung_eintragen') do
      click_on first("Aktivmeldung eintragen")
    end

    page.should have_content "Aktivmeldung eintragen"
    
    within '#user_add_to_corporation_input' do
      page.should have_content @my_corporations.first.title
      page.should have_content @my_corporations.second.title
      page.should have_no_content @other_corporation.title
    end
    
    
    fill_in I18n.t(:first_name), with: "Bundesbruder"
    fill_in I18n.t(:last_name), with: "Kanne"
    select "13", from: 'user_date_of_birth_3i' # formtastic day
    select "November", from: 'user_date_of_birth_2i' # formtastic month
    select "1986", from: 'user_date_of_birth_1i' # formtastic year
    
    @aktivmeldungsjahr = Time.now.year - 2
    select @corporation.title, from: I18n.t(:register_in)
    select "2", from: 'user_aktivmeldungsdatum_3i' # formtastic day
    select "Dezember", from: 'user_aktivmeldungsdatum_2i' # formtastic month
    select @aktivmeldungsjahr, from: 'user_aktivmeldungsdatum_1i' # formtastic year
    
    fill_in I18n.t('activerecord.attributes.user.study_address'), with: "Some Address"
    fill_in I18n.t('activerecord.attributes.user.home_address'), with: "44 Rue de Stalingrad, Grenoble, Frankreich"
    fill_in I18n.t(:email), with: "bbr.kanne@example.com"
    fill_in I18n.t(:phone), with: "09131 123 45 56"
    fill_in I18n.t(:mobile), with: "0161 142 82 20 20 2"
    
    check I18n.t(:create_account)
    
    click_on "Aktivmeldung bestätigen"

    # Jetzt ist man wieder auf der Startseite.
    # Dort gibt es den Benutzer in der Box der Aktivmeldungen.
    
    page.should have_text 'Aktivmeldungen'
    click_on User.last.uncached(:title)
    
    page.should have_content "Bundesbruder Kanne"
    page.should have_content User.last.title
    
    page.should have_content I18n.t(:date_of_birth)
    page.should have_content "13.11.1986"
     
    page.should have_content I18n.t(:personal_title)
    page.should have_content I18n.t(:academic_degree)
    page.should have_content I18n.t(:cognomen)
    page.should have_content I18n.t(:klammerung)
    
    page.should have_content I18n.t(:email)
    page.should have_content "bbr.kanne@example.com"
    
    page.should have_content "Heimatanschrift"
    page.should have_content "44 Rue de Stalingrad, Grenoble, Frankreich"
    
    page.should have_content "Semesteranschrift"
    page.should have_content "Some Address"
    page.should have_no_content I18n.t(:work_or_study_address)
    
    page.should have_content I18n.t(:phone)
    page.should have_content "09131 123 45 56"
    page.should have_content I18n.t(:mobile)
    page.should have_content "0161 142 82 20 20 2"
    page.should have_content I18n.t(:fax)
    page.should have_content I18n.t(:homepage)
    
    page.should have_content I18n.t(:study)
    
    page.should have_content I18n.t(:professional_category)
    page.should have_content I18n.t(:occupational_area)
    page.should have_content I18n.t(:employment_status)
    page.should have_content I18n.t(:languages)
    
    page.should have_content I18n.t(:bank_account)
    
    page.should have_content @corporation.title
    page.should have_content "02.12.#{@aktivmeldungsjahr}"
    
    page.should have_content I18n.t(:name_field_wingolfspost)
    page.should have_content I18n.t(:wbl_abo)

  end
  
  scenario "leaving out a non-required field" do
    login @local_admin_user
    
    visit root_path
    within('.aktivmeldung_eintragen') do
      click_on first("Aktivmeldung eintragen")
    end

    fill_in I18n.t(:first_name), with: "Bundesbruder"
    fill_in I18n.t(:last_name), with: "Kanne"
    select "13", from: 'user_date_of_birth_3i' # formtastic day
    select "November", from: 'user_date_of_birth_2i' # formtastic month
    select "1986", from: 'user_date_of_birth_1i' # formtastic year
    
    @aktivmeldungsjahr = Time.now.year - 2
    select @corporation.title, from: I18n.t(:register_in)
    select "2", from: 'user_aktivmeldungsdatum_3i' # formtastic day
    select "Dezember", from: 'user_aktivmeldungsdatum_2i' # formtastic month
    select @aktivmeldungsjahr, from: 'user_aktivmeldungsdatum_1i' # formtastic year
    
    fill_in I18n.t('activerecord.attributes.user.study_address'), with: "Some Address"
    fill_in I18n.t('activerecord.attributes.user.home_address'), with: "44 Rue de Stalingrad, Grenoble, Frankreich"
    fill_in I18n.t(:email), with: "bbr.kanne@example.com"
    
    # Leaving out this field: 
    # fill_in I18n.t(:phone), with: "09131 123 45 56"
    
    fill_in I18n.t(:mobile), with: "0161 142 82 20 20 2"
    
    check I18n.t(:create_account)
    
    click_on "Aktivmeldung bestätigen"

    # Jetzt ist man wieder auf der Startseite.
    # Dort gibt es den Benutzer in der Box der Aktivmeldungen.
    
    page.should have_text 'Aktivmeldungen'
    click_on User.last.uncached(:title)
    
    page.should have_content "Bundesbruder Kanne"
    page.should have_content User.last.title
    
    page.should have_content I18n.t(:date_of_birth)
    page.should have_content "13.11.1986"
     
    page.should have_content I18n.t(:personal_title)
    page.should have_content I18n.t(:academic_degree)
    page.should have_content I18n.t(:cognomen)
    page.should have_content I18n.t(:klammerung)
    
    page.should have_content I18n.t(:email)
    page.should have_content "bbr.kanne@example.com"
    
    page.should have_content "Heimatanschrift"
    page.should have_content "44 Rue de Stalingrad, Grenoble, Frankreich"
    
    page.should have_content "Semesteranschrift"
    page.should have_content "Some Address"
    page.should have_no_content I18n.t(:work_or_study_address)
    
    page.should have_content I18n.t(:phone)
    page.should have_no_content "09131 123 45 56"
    page.should have_content I18n.t(:mobile)
    page.should have_content "0161 142 82 20 20 2"
    page.should have_content I18n.t(:fax)
    page.should have_content I18n.t(:homepage)
    
    page.should have_content I18n.t(:study)
    
    page.should have_content I18n.t(:professional_category)
    page.should have_content I18n.t(:occupational_area)
    page.should have_content I18n.t(:employment_status)
    page.should have_content I18n.t(:languages)
    
    page.should have_content I18n.t(:bank_account)
    
    page.should have_content @corporation.title
    page.should have_content "02.12.#{@aktivmeldungsjahr}"
    
    page.should have_content I18n.t(:name_field_wingolfspost)
    page.should have_content I18n.t(:wbl_abo)
  end
  
  scenario "leaving out the corporation as global admin" do
    login :global_admin
    
    visit root_path
    within('.aktivmeldung_eintragen') do
      click_on first("Aktivmeldung eintragen")
    end

    fill_in I18n.t(:first_name), with: "Bundesbruder"
    fill_in I18n.t(:last_name), with: "Kanne"
    select "13", from: 'user_date_of_birth_3i' # formtastic day
    select "November", from: 'user_date_of_birth_2i' # formtastic month
    select "1986", from: 'user_date_of_birth_1i' # formtastic year
    
    @aktivmeldungsjahr = Time.now.year - 2
    
    # Leaving out this field: 
    # select @corporation.title, from: I18n.t(:register_in)
    
    select "2", from: 'user_aktivmeldungsdatum_3i' # formtastic day
    select "Dezember", from: 'user_aktivmeldungsdatum_2i' # formtastic month
    select @aktivmeldungsjahr, from: 'user_aktivmeldungsdatum_1i' # formtastic year
    
    fill_in I18n.t('activerecord.attributes.user.study_address'), with: "Some Address"
    fill_in I18n.t('activerecord.attributes.user.home_address'), with: "44 Rue de Stalingrad, Grenoble, Frankreich"
    fill_in I18n.t(:email), with: "bbr.kanne@example.com"
    fill_in I18n.t(:phone), with: "09131 123 45 56"
    fill_in I18n.t(:mobile), with: "0161 142 82 20 20 2"
    
    check I18n.t(:create_account)
    
    click_on "Aktivmeldung bestätigen"

    # Jetzt ist man wieder auf der Startseite.
    # Dort gibt es den Benutzer nicht in der Box der Aktivmeldungen, da er nicht als Wingolfit eingetragen wurde.
    page.should have_text 'Aktivmeldungen'
    page.should have_no_text User.last.uncached(:title)
    
    visit user_path(User.where(last_name: 'Kanne').last)
    
    page.should have_content "Bundesbruder Kanne"
    page.should have_content User.last.title
    
    page.should have_content I18n.t(:date_of_birth)
    page.should have_content "13.11.1986"
     
    page.should have_content I18n.t(:personal_title)
    page.should have_content I18n.t(:academic_degree)
    page.should have_content I18n.t(:cognomen)
    page.should have_content I18n.t(:klammerung)
    
    page.should have_content I18n.t(:email)
    page.should have_content "bbr.kanne@example.com"
    
    page.should have_content "Heimatanschrift"
    page.should have_content "44 Rue de Stalingrad, Grenoble, Frankreich"
    
    page.should have_content "Semesteranschrift"
    page.should have_content "Some Address"
    page.should have_no_content I18n.t(:work_or_study_address)
    
    page.should have_content I18n.t(:phone)
    page.should have_content "09131 123 45 56"
    page.should have_content I18n.t(:mobile)
    page.should have_content "0161 142 82 20 20 2"
    page.should have_content I18n.t(:fax)
    page.should have_content I18n.t(:homepage)
    
    page.should have_content I18n.t(:study)
    
    page.should have_content I18n.t(:professional_category)
    page.should have_content I18n.t(:occupational_area)
    page.should have_content I18n.t(:employment_status)
    page.should have_content I18n.t(:languages)
    
    page.should have_content I18n.t(:bank_account)
    
    # Es sollte kein Eintrag in der wingolfitischen Vita vorhanden sein:
    page.should have_no_content @corporation.title
    page.should have_no_content "02.12.#{@aktivmeldungsjahr}"
    
    page.should have_content I18n.t(:name_field_wingolfspost)
    page.should have_content I18n.t(:wbl_abo)
  end
  
  scenario "leaving out the corporation as local admin" do
    login @local_admin_user
    
    visit root_path
    within('.aktivmeldung_eintragen') do
      click_on first("Aktivmeldung eintragen")
    end

    fill_in I18n.t(:first_name), with: "Bundesbruder"
    fill_in I18n.t(:last_name), with: "Kanne"
    select "13", from: 'user_date_of_birth_3i' # formtastic day
    select "November", from: 'user_date_of_birth_2i' # formtastic month
    select "1986", from: 'user_date_of_birth_1i' # formtastic year
    
    @aktivmeldungsjahr = Time.now.year - 2
    
    # Leaving out this field: 
    # select @corporation.title, from: I18n.t(:register_in)
    
    select "2", from: 'user_aktivmeldungsdatum_3i' # formtastic day
    select "Dezember", from: 'user_aktivmeldungsdatum_2i' # formtastic month
    select @aktivmeldungsjahr, from: 'user_aktivmeldungsdatum_1i' # formtastic year
    
    fill_in I18n.t('activerecord.attributes.user.study_address'), with: "Some Address"
    fill_in I18n.t('activerecord.attributes.user.home_address'), with: "44 Rue de Stalingrad, Grenoble, Frankreich"
    fill_in I18n.t(:email), with: "bbr.kanne@example.com"
    fill_in I18n.t(:phone), with: "09131 123 45 56"
    fill_in I18n.t(:mobile), with: "0161 142 82 20 20 2"
    
    check I18n.t(:create_account)
    
    click_on "Aktivmeldung bestätigen"
    
    page.should have_text "Es wurde keine Verbindung angegeben. Die Aktivmeldung konnte nicht eingetragen werden."
    
    # Da ein Pflichtfeld fehlt, ist man nach wie vor auf der Seite "Aktivmeldung eintragen".
    page.should have_text "Aktivmeldung eintragen"
    page.should have_text "Informationen zur Aktivmeldung wurden nicht vollständig ausgefüllt."
    page.should have_no_text "Philistrationen" # Das wäre die Startseite.
    
    # Die vormals eingetragenen Informationen sollen aber beibehalten sein.
    page.should have_selector("input[value='Bundesbruder']")
    page.should have_selector("input[value='Kanne']")
  end
  
  scenario "leaving out the aktivmeldungsdatum" do
    login @local_admin_user
    
    visit root_path
    within('.aktivmeldung_eintragen') do
      click_on first("Aktivmeldung eintragen")
    end

    fill_in I18n.t(:first_name), with: "Bundesbruder"
    fill_in I18n.t(:last_name), with: "Kanne"
    select "13", from: 'user_date_of_birth_3i' # formtastic day
    select "November", from: 'user_date_of_birth_2i' # formtastic month
    select "1986", from: 'user_date_of_birth_1i' # formtastic year
    
    @aktivmeldungsjahr = Time.now.year - 2
    select @corporation.title, from: I18n.t(:register_in)

    # Leaving out this field: 
    # select "2", from: 'user_aktivmeldungsdatum_3i' # formtastic day
    # select "Dezember", from: 'user_aktivmeldungsdatum_2i' # formtastic month
    # select @aktivmeldungsjahr, from: 'user_aktivmeldungsdatum_1i' # formtastic year
    
    fill_in I18n.t('activerecord.attributes.user.study_address'), with: "Some Address"
    fill_in I18n.t('activerecord.attributes.user.home_address'), with: "44 Rue de Stalingrad, Grenoble, Frankreich"
    fill_in I18n.t(:email), with: "bbr.kanne@example.com"
    fill_in I18n.t(:phone), with: "09131 123 45 56"
    fill_in I18n.t(:mobile), with: "0161 142 82 20 20 2"
    
    check I18n.t(:create_account)
    
    click_on "Aktivmeldung bestätigen"

    # Jetzt ist man wieder auf der Startseite.
    page.should have_text 'Aktivmeldungen'
    click_on User.last.uncached(:title)
    
    page.should have_content "Bundesbruder Kanne"
    page.should have_content User.last.title
    
    page.should have_content I18n.t(:date_of_birth)
    page.should have_content "13.11.1986"
     
    page.should have_content I18n.t(:personal_title)
    page.should have_content I18n.t(:academic_degree)
    page.should have_content I18n.t(:cognomen)
    page.should have_content I18n.t(:klammerung)
    
    page.should have_content I18n.t(:email)
    page.should have_content "bbr.kanne@example.com"
    
    page.should have_content "Heimatanschrift"
    page.should have_content "44 Rue de Stalingrad, Grenoble, Frankreich"
    
    page.should have_content "Semesteranschrift"
    page.should have_content "Some Address"
    page.should have_no_content I18n.t(:work_or_study_address)
    
    page.should have_content I18n.t(:phone)
    page.should have_content "09131 123 45 56"
    page.should have_content I18n.t(:mobile)
    page.should have_content "0161 142 82 20 20 2"
    page.should have_content I18n.t(:fax)
    page.should have_content I18n.t(:homepage)
    
    page.should have_content I18n.t(:study)
    
    page.should have_content I18n.t(:professional_category)
    page.should have_content I18n.t(:occupational_area)
    page.should have_content I18n.t(:employment_status)
    page.should have_content I18n.t(:languages)
    
    page.should have_content I18n.t(:bank_account)
    
    # Als Aktivmeldungsdatum wird das aktuelle Datum verwendet, wenn kein Datum angegeben ist.
    within '#corporate_vita' do
      page.should have_content @corporation.title
      page.should have_no_content "02.12.#{@aktivmeldungsjahr}"
      page.should have_content I18n.localize(Date.today)
    end
    
    page.should have_content I18n.t(:name_field_wingolfspost)
    page.should have_content I18n.t(:wbl_abo)
  end
  
  scenario "leaving out a required field when entering aktivmeldung", :js do
    login @local_admin_user

    visit root_path
    within('.aktivmeldung_eintragen') do
      click_on first("Aktivmeldung eintragen")
    end

    fill_in I18n.t(:first_name), with: "Bundesbruder"
    fill_in I18n.t(:last_name), with: "Kanne"
    select "13", from: 'user_date_of_birth_3i' # formtastic day
    select "November", from: 'user_date_of_birth_2i' # formtastic month
    select "1986", from: 'user_date_of_birth_1i' # formtastic year
    
    @aktivmeldungsjahr = Time.now.year - 2
    select @corporation.title, from: I18n.t(:register_in)
    select "2", from: 'user_aktivmeldungsdatum_3i' # formtastic day
    select "Dezember", from: 'user_aktivmeldungsdatum_2i' # formtastic month
    select @aktivmeldungsjahr, from: 'user_aktivmeldungsdatum_1i' # formtastic year
    
    # NICHT AUSFÜLLEN: 
    # fill_in I18n.t('activerecord.attributes.user.study_address'), with: "Some Address"
    
    fill_in I18n.t('activerecord.attributes.user.home_address'), with: "44 Rue de Stalingrad, Grenoble, Frankreich"
    fill_in I18n.t(:email), with: "bbr.kanne@example.com"
    fill_in I18n.t(:phone), with: "09131 123 45 56"
    fill_in I18n.t(:mobile), with: "0161 142 82 20 20 2"
    
    check I18n.t(:create_account)
    
    click_on "Aktivmeldung bestätigen"

    # Da ein Pflichtfeld fehlt, ist man nach wie vor auf der Seite "Aktivmeldung eintragen".
    page.should have_text "Aktivmeldung eintragen"
    page.should have_text "Informationen zur Aktivmeldung wurden nicht vollständig ausgefüllt."
    page.should have_no_text "Philistrationen" # Das wäre die Startseite.
    
    # Die vormals eingetragenen Informationen sollen aber beibehalten sein.
    page.should have_selector("input[value='Bundesbruder']")
    page.should have_selector("input[value='Kanne']")
    
    # TODO: Diese Felder überprüfen, wenn wir ClientSide-Validation haben.
    # page.should have_text "09131 123 45 56"
    # page.should have_text "0161 142 82 20 20 2"
  end
  
  pending "with account"
  
  # FIXME: Benutzer erscheint danach nicht auf Startseite.

end
