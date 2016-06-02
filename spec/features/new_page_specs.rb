require 'spec_helper'

feature "New Page" do
  include SessionSteps

  background do
    @page = create :page
    login :admin
    visit page_path(@page)
  end

  scenario "creating a new blog post" do
    click_on I18n.t(:new_page)
    within '#new_page_modal' do
      fill_in :page_title, with: "This is my new blog post!"
      choose I18n.t(:display_the_new_page_as_blog_post)
      click_on I18n.t(:confirm)
    end
    within '.box.first' do
      within '.panel-title' do
        page.should have_text "This is my new blog post!"
      end
      Page.last.type.should == "BlogPost"
      Page.last.parent_pages.first.should == @page
    end

    visit page_path(@page)
    within '#vertical_nav' do
      page.should_not have_text "This is my new blog post!"
    end
    within '#content_area' do
      page.should have_text "This is my new blog post!"
    end
  end

  scenario "creating a new regular page" do
    click_on I18n.t(:new_page)
    within '#new_page_modal' do
      fill_in :page_title, with: "This is my new regular page."
      choose I18n.t(:display_the_new_page_as_regular_page)
      click_on I18n.t(:confirm)
    end
    within '.box.first' do
      within '.panel-title' do
        page.should have_text "This is my new regular page."
      end
      Page.last.type.should == nil
      Page.last.parent_pages.first.should == @page
    end
  end

  scenario "creating a new regular page shown in the menu" do
    click_on I18n.t(:new_page)
    within '#new_page_modal' do
      fill_in :page_title, with: "This is my new regular page."
      choose I18n.t(:display_the_new_page_as_regular_page)
      check I18n.t(:display_the_new_page_in_the_nav)
      click_on I18n.t(:confirm)
    end
    within '.box.first' do
      within '.panel-title' do
        page.should have_text "This is my new regular page."
      end
      Page.last.type.should == nil
      Page.last.parent_pages.first.should == @page
      Page.last.nav_node.hidden_menu.should == false
    end

    visit page_path(@page)
    within '#vertical_nav' do
      page.should have_text "This is my new regular page."
    end
  end

  scenario "creating a new regular page hidden in the menu" do
    click_on I18n.t(:new_page)
    within '#new_page_modal' do
      fill_in :page_title, with: "This is my new regular page."
      choose I18n.t(:display_the_new_page_as_regular_page)
      uncheck I18n.t(:display_the_new_page_in_the_nav)
      click_on I18n.t(:confirm)
    end
    within '.box.first' do
      within '.panel-title' do
        page.should have_text "This is my new regular page."
      end
      Page.last.type.should == nil
      Page.last.parent_pages.first.should == @page
      Page.last.nav_node.hidden_menu.should == true
    end

    visit page_path(@page)
    within '#vertical_nav' do
      page.should_not have_text "This is my new regular page."
    end
  end

  scenario "creating a new regular page shown as teaser box" do
    click_on I18n.t(:new_page)
    within '#new_page_modal' do
      fill_in :page_title, with: "This is my new regular page."
      choose I18n.t(:display_the_new_page_as_regular_page)
      check I18n.t(:display_the_new_page_as_teaser_box)
      click_on I18n.t(:confirm)
    end
    within '.box.first' do
      within '.panel-title' do
        page.should have_text "This is my new regular page."
      end
      Page.last.type.should == nil
      Page.last.parent_pages.first.should == @page
      Page.last.nav_node.hidden_teaser_box.should == false
    end

    visit page_path(@page)
    within '#content_area' do
      page.should have_text "This is my new regular page."
    end
  end

  scenario "creating a new regular page not shown as teaser box" do
    click_on I18n.t(:new_page)
    within '#new_page_modal' do
      fill_in :page_title, with: "This is my new regular page."
      choose I18n.t(:display_the_new_page_as_regular_page)
      uncheck I18n.t(:display_the_new_page_as_teaser_box)
      click_on I18n.t(:confirm)
    end
    within '.box.first' do
      within '.panel-title' do
        page.should have_text "This is my new regular page."
      end
      Page.last.type.should == nil
      Page.last.parent_pages.first.should == @page
      Page.last.nav_node.hidden_teaser_box.should == true
    end

    visit page_path(@page)
    within '#content_area' do
      page.should_not have_text "This is my new regular page."
    end
  end

  scenario "creating a new hidden page" do
    click_on I18n.t(:new_page)
    within '#new_page_modal' do
      fill_in :page_title, with: "This is my new hidden page."
      choose I18n.t(:hide_the_new_page)
      click_on I18n.t(:confirm)
    end
    within '.box.first' do
      within '.panel-title' do
        page.should have_text "This is my new hidden page."
      end
      Page.last.type.should == nil
      Page.last.parent_pages.first.should == @page
      Page.last.nav_node.hidden_menu.should == true
      Page.last.nav_node.hidden_teaser_box.should == true
    end

    visit page_path(@page)
    within '#content_area' do
      page.should_not have_text "This is my new hidden page."
    end
    within '#horizontal_nav' do
      page.should_not have_text "This is my new hidden page."
    end
    within '#vertical_nav' do
      page.should_not have_text "This is my new hidden page."
    end
  end




end