require 'spec_helper'

feature "Viewing pages that redirect to other locations", js: true do
  include SessionSteps
  
  background do
    @root = Page.find_root
    @root.redirect_to = "http://example.com"
    @root.title = "example.com"
    @root.save
    @intranet_root = Page.find_intranet_root
  end
  scenario "Clicking on a breadcrumb link that redirects to an external website" do
    login(:user)
    
    visit page_path(@intranet_root)
    within "#breadcrumb" do
      click_on "example.com"
    end
    
    page.should have_content "Example Domain"
  end
end
