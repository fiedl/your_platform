# -*- coding: utf-8 -*-
require 'spec_helper'
include SessionSteps

feature "Viewing a Page" do
  background do
    login :user
    @page = Page.create(title: "My Shiny Page")
  end
  scenario "Visiting the page" do
    visit page_path(@page)
    page.should have_content "My Shiny Page"
  end
  scenario "Visiting the page 'My Shiny Page' and afterwards the page 'Intranet Root'" do
    visit page_path(@page)
    click_on("Intranet")
    page_title = page.all('title', :text => "Intranet - Wingolfsplattform")
    page_title.class.to_s.should == "Capybara::Result"
  end
end
