require 'spec_helper'

feature 'Locales' do
  include SessionSteps
  
  before do
    @user = create(:user_with_account)
    login(@user)
  end
  
  scenario "providing the :locale parameter to display the page in different languages" do
    
    # providing the url parameter should change the locale.
    #
    visit user_path(@user, :locale => :de)
    page.should have_text "Mein Profil"
    visit user_path(@user, :locale => :en)
    page.should have_text "My Profile"
    
    # the locale should be kept when visiting another page (using a cookie).
    #
    visit root_path
    page.should have_text "My Profile"
    page.should_not have_text "Mein Profil"

  end

end
