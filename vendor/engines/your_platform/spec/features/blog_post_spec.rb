require 'spec_helper'

feature "Adding a BlogPost", :js do
  include SessionSteps
  
  background do
    @page = Page.create(title: "My Shiny Page")
  end
  scenario "Adding a blog post" do
    login(:admin)
    visit page_path(@page)
    #page.save_screenshot('tmp/screenshot4.png')

    click_on I18n.t(:add_blog_post)
    #page.save_screenshot('tmp/screenshot5.png')
    wait_for_ajax;
    wait_for_ajax;
    # After clicking the link to add a blog post, there should be a new blog post
    # that is already in edit_mode.
    #page.save_screenshot('tmp/screenshot6.png')
    page.should have_selector ".best_in_place.editable input[type='text']"

  end
end
