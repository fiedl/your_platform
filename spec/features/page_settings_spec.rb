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

    wait_for_best_in_place 'tr.page_author'

    visit page_path(@page)
    within '.page_author' do
      page.should have_text @new_author.title
    end

    @page.reload.author.should == @new_author
  end

  scenario "setting the page type" do
    login :admin
    visit page_settings_path(@page)

    select_in_place 'tr.page_type', 'BlogPost'

    visit page_path(@page)
    @page.reload.type.should == "BlogPost"
  end

  describe "for home pages" do
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
end