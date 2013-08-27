require 'spec_helper'

feature 'Locales' do
  include SessionSteps
  
  before do
    @user = create(:user_with_account)
    login(@user)
  end
  
  scenario "providing the :locale parameter to display the page in different languages" do
    visit user_path(@user, :locale => :de)
    page.should have_text "Mein Profil"
    visit user_path(@user, :locale => :en)
    page.should have_text "My Profile"
  end

end
