require 'spec_helper'

feature "Page settings", js: true do
  include SessionSteps

  before do
    @page = Pages::HomePage.create title: "example.com", content: "Test home page"
    @sub_page = @page.child_pages.create title: "Sub page"
    @second_sub_page = @page.child_pages.create title: "Second page"

    login :admin
  end

  scenario "Showing the sub page as teaser box" do
    visit page_settings_path(@page)
    within(".box.boxes_on_this_page form#edit_page_#{@sub_page.id}") do
      check "Sub page"
    end
    within(".box.boxes_on_this_page form#edit_page_#{@second_sub_page.id}") do
      uncheck "Second page"
    end
    click_on I18n.t(:back_to_the_page)

    within('.row.box_configuration') do
      page.should have_selector "#page-#{@sub_page.id}-box.page.box"
      page.should have_no_selector "#page-#{@second_sub_page.id}-box.page.box"
    end
    within("#page-#{@sub_page.id}-box.page.box") do
      page.should have_text @sub_page.title
    end
    within('#content') do
      page.should have_no_text @second_sub_page.title
    end
  end

  scenario "Hiding the sub page as teaser box" do
    visit page_settings_path(@page)
    within(".box.boxes_on_this_page form#edit_page_#{@sub_page.id}") do
      uncheck "Sub page"
    end
    click_on I18n.t(:back_to_the_page)

    within('.row.box_configuration') do
      page.should have_no_selector "#page-#{@sub_page.id}-box.page.box"
    end
    within('#content') do
      page.should have_no_text @sub_page.title
    end
  end

end