require 'spec_helper'

feature "Issues", :js do
  include SessionSteps

  scenario "Fixing an issue where a postal address has too many lines" do
    @person = create :user
    @name_surrounding_field = @person.profile_fields.create type: 'ProfileFields::NameSurrounding'
    @name_surrounding_field.text_below_name = "Student"
    @name_surrounding_field.save
    @address_field = @person.profile_fields.create type: 'ProfileFields::Address', label: 'Study address'
    @address_field.first_address_line = "King's Parade"
    @address_field.second_address_line = "King's College"
    @address_field.postal_code = "CB2 1ST"
    @address_field.city = "Cambridge"
    @address_field.region = "Cambridgeshire"
    @address_field.country_code = 'GB'
    @address_field.save

    # We have some strange timing issues here.
    # Automatic cache renew does not kick in, especially on travis.
    wait_until { Rails.cache.uncached { @address_field.profileable.name_with_surrounding }.include? "Student" }

    Issue.count.should == 0
    Issue.scan(@address_field)
    Issue.count.should == 1

    login :admin
    visit issues_path

    page.should have_text "Student"
    page.should have_text "Cambridgeshire"
    page.should have_text "King's College"

    # The admin tries to save some space here: The address is allowed to take up
    # up to four lines:

    click_on :edit
    enter_in_edit_mode 'li.region', "-"
    enter_in_edit_mode 'li.first_address_line', "King's College, King's Parade"
    enter_in_edit_mode 'li.second_address_line', "-"
    click_on :save

    page.should have_text t(:scanning_issue)
    page.should have_no_text t(:scanning_issue)
    page.should have_text t(:thanks)

    @address_field.reload.region.should be_blank

    Issue.scan(@address_field)
    Issue.count.should == 0
  end

end