require 'spec_helper'

feature "Move Pages" do
  scenario "moving a page to a new parent page", :js do
    @page = create :page, title: "My Page", published_at: 1.year.ago
    @parent_page = create(:page, title: "Parent Page", published_at: 1.year.ago); @parent_page << @page
    @new_parent_page = create :page, title: "New Parent", published_at: 1.year.ago

    login :admin
    visit page_path @page

    find(".box .box_header .edit_button").hover
    find(".box .box_header .relocate_page_button").click

    find(".page_title_select").set("New")
    find(".page_title_select").native.send_keys(:return)
    within ".page_search_results" do
      click_on "New Parent"
    end
    within ".box" do
      click_on "OK"
    end

    within ".box_title" do
      page.should have_text "My Page"
    end
    within ".vertical_nav" do
      page.should have_text "New Parent"
    end

    @page.reload.parent_pages.pluck(:id).should include @new_parent_page.id
    @page.parent_pages.pluck(:id).should_not include @parent_page.id
  end
end