require 'spec_helper'

feature "Page Permalinks", :js do
  include SessionSteps

  background do
    @page = create :page, title: "This is my page!"
  end

  scenario "setting a page permalink" do
    login :admin
    visit page_permalinks_path(@page)

    within ".box.permalinks" do
      click_on :edit
      fill_in "permalinks_list", with: "foo/bar\n"
      click_on :save
    end

    wait_for_ajax
    visit page_path(@page)
    @page.reload.permalinks.reload.count.should == 1
    @page.reload.permalinks_list.should include "foo/bar"

    visit "/foo/bar"
    page.should have_text "This is my page!"
  end

end