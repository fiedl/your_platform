require 'spec_helper'

feature "Help Page" do
  include SessionSteps
  background do
    login :user
    @help_page = Page.create_help_page
    @help_page.update_attributes( title: I18n.t( :help ) )
  end

  scenario "clicking on the help button and viewing the help page" do
    visit root_path
    click_on I18n.t(:help)

    within("#content_area") do
      page.should have_content I18n.t(:help)
    end
  end

end
