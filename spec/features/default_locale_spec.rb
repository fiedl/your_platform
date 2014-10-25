require 'spec_helper'

feature 'Default Locale' do
  include SessionSteps

  before do
    @user = create(:user_with_account)
    login(:admin)
  end

  scenario "visiting the profile in order to make sure the default locale is :de" do
    visit user_path(@user)
    within ".box.section.access" do
      page.should have_text "Zugangsdaten"
      page.should have_text "E-Mail"
      page.should have_no_text "Email"
    end
  end

end
