require 'spec_helper'

feature "Sign Out" do
  include SessionSteps
  
  before do
    @user = create :user_with_account
    login @user
    visit user_path(@user)
  end
  
  scenario "signing out through /sign_out (bug fix)" do
    # This has mistakenly been routed to users#show with {alias: 'sign_out'}.
    # (Bug Fix.)
    page.driver.submit :delete, "/sign_out", {}

    page.should have_text "Anmelden"
  end

  scenario "signing out through /user_accounts/sign_out" do
    page.driver.submit :delete, "/user_accounts/sign_out", {}
    
    page.should have_text "Anmelden"
  end
  
  scenario "clicking on the sign-out link" do
    find('.current_user_dropdown').click
    find('#sign_out').click
    
    page.should have_text "Anmelden"
  end

end