require 'spec_helper'

feature "Help Button" do
  include SessionSteps

  before do
    @help_page = Page.create(name: "Help")
    @help_page.add_flag :help
    
    @start_page = Page.intranet_root.child_pages.create(title: "Start Page")
    login :user
  end
  
  scenario 'visiting a page and use the help button', js: true do
    visit page_path(@start_page)
    click_on I18n.t(:help)

    page.should have_selector('div.uv-popover-iframe-container', visible: true)
  end
end
  