require 'spec_helper'

feature 'Setup' do
  include SessionSteps

  describe 'for a clean database' do

    before { DatabaseCleaner.clean }
    around :each do |example|
       Rails.application.config.action_dispatch.show_exceptions = true
       example.run
       Rails.application.config.action_dispatch.show_exceptions = false
    end

    scenario 'using the application setup', :js do

      visit root_path
      page.should have_text I18n.t :this_setup_will_get_you_up_and_running

      confirm_cookies_notice

      fill_in :first_name, with: 'John'
      fill_in :last_name, with: 'Doe'
      fill_in :email, with: 'j.doe@example.com'
      fill_in :password, with: 'aif5Ahzae6Ahweng1OZeiqu3'
      fill_in :password_confirmation, with: 'aif5Ahzae6Ahweng1OZeiqu3'
      fill_in :application_name, with: 'My New Network Application'
      fill_in :sub_organizations, with: "London\nBerlin\nParis\nNew York"

      click_on I18n.t :confirm

      wait_until { page.has_text? t(:setup_complete) }

      accept_terms_of_use
      @user = User.first

      within '#header-nav' do
        page.should have_selector '.avatar'
        page.should have_text 'London'
        page.should have_no_text 'Berlin'
        page.should have_text Page.find_intranet_root.title
      end
      #within '#logged-in-bar' do
      #  page.should have_text I18n.t :global_admin
      #end

      visit setup_path
      page.should have_text 'Setup already done.'
      page.should have_no_text I18n.t :this_setup_will_get_you_up_and_running

    end
  end
end