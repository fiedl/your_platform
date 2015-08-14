require 'spec_helper'

feature "Merit Badge Rules" do
  include SessionSteps
  
  background do
    @user = create :user_with_account
  end
  
  scenario "calendar-uplink badge" do
    login @user

    # Just looking at events#index does nothing.
    visit events_path
    @user.reload.badges.map(&:name).should_not include 'calendar-uplink'

    # Downloading the ical feed should grant the calendar-uplink badge.
    visit events_path(format: 'ics', protocol: 'webcal', token: @user.account.auth_token)
    @user.reload.badges.map(&:name).should include 'calendar-uplink'
  end
  
end