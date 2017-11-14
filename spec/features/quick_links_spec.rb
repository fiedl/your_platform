require 'spec_helper'

feature "Quick Links", :js do
  include SessionSteps

  before do
    @linked_page1 = create :page, title: "First page title", content: "Linked page 1", published_at: 1.year.ago
    @linked_page2 = create :page, title: "Second page title", content: "Linked page 2", published_at: 1.year.ago
    @root_page = Page.find_root
    @root_page.content = "This root page links to [[First page title]] and [[Second page title]]."
    @root_page.save

    login :user
  end

  scenario "checking that the wiki syntax created two links" do
    visit page_path(@root_page)
    click_on "First page title"
    page.should have_text "Linked page 1"

    visit page_path(@root_page)
    click_on "Second page title"
    page.should have_text "Linked page 2"
  end
end