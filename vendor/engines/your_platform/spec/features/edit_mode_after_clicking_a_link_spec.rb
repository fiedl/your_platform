require 'spec_helper'

feature "edit mode after clicking a link" do
  include SessionSteps

  scenario "switch to edit mode after clicking a link (turbolinks support)" do
    login(:admin)
    visit root_path
    
    # switch to another page (turbolinks)
    first(:link, I18n.t(:my_profile)).click

    # edit mode should still work
    within(".box.section.contact_information") do
      click_on I18n.t(:edit)
      page.should have_content I18n.t(:add)
    end

  end
end
