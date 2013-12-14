require 'spec_helper'

feature "Viewing the intranet root page" do
  scenario "Visiting the page" do
    
    # The user is *not* logged in. 
    # Just visit the start page.
    visit root_path
    
    # This should redirect to the login page.
    within("#content_area") do
      page.should have_content I18n.t(:login)
    end
    
  end
end
