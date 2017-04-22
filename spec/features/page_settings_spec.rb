require 'spec_helper'

feature "Page Settings", :js do
  include SessionSteps

  background do
    @page = create :page
    @new_author = create :user
  end

  scenario "setting the page author" do
    login :admin
    visit page_settings_path(@page)

    within ".box.page_settings" do
      click_on :edit
      within "tr.page_author" do
        fill_in "author_title", with: @new_author.title
      end
      click_on :save
    end

    wait_for_ajax
    @page.reload.author.should == @new_author
  end

  scenario "setting the page type" do
    login :admin
    visit page_settings_path(@page)

    within ".box.page_settings" do
      click_on :edit
      within "tr.page_type" do
        select "BlogPost"
      end
      click_on :save
    end

    visit page_path(@page)
    @page.reload.type.should == "BlogPost"
  end

end