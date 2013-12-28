require 'spec_helper'

feature 'Impressum' do
  include SessionSteps
  
  describe 'for an imprint Page existing' do
    background do 
      @imprint = Page.create(title: "Imprint", content: "This is the imprint.")
      @imprint.add_flags :imprint
    end
    scenario 'clicking on the imprint link in the footer' do
      login(:user)
      visit root_path
      
      within "#footer" do
        click_on I18n.t(:imprint)
      end
      
      page.should have_content "This is the imprint."
    end
    scenario 'viewing imprint if not logged in' do
      visit root_path
      within "#footer" do
        click_on I18n.t(:imprint)
      end
      page.should have_content "This is the imprint."
    end
  end
  
  describe 'for no imprint Page existing' do
    scenario 'clicking on the imprint link in the footer' do
      login(:user)
      visit root_path
      
      within "#footer" do
        expect { click_on I18n.t(:imprint) }.not_to raise_error
      end

    end
  end
end
