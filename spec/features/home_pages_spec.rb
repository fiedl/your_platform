require 'spec_helper'

feature "Home Pages" do
  context "As homepage admin" do
    background do
      @user = create :user_with_account
      @page = Page.create title: "example.com", published_at: 1.day.ago
      @page.settings.layout = 'strappy'
      @page.assign_admin @user
      wait_for_cache
    end

    scenario "Creating a home page with layout", :js do
      login @user
      visit page_path @page

      find('a#page_settings_button').click
      select_in_place "tr.page_type", 'Pages::HomePage'

      click_on :back_to_the_page
      within('#site_tools') do
        find('a#page_settings_button').click # in order to load the home page settings.
      end

      select_in_place 'tr.layout', 'iweb'
      enter_in_place 'tr.home_page_title', 'Example, Corp.'
      enter_in_place 'tr.home_page_sub_title', 'The place to be. Since 1850.'

      click_on :back_to_the_page

      within "#header" do
        expect(page).to have_text "Example, Corp."
        expect(page).to have_text "The place to be. Since 1850."
      end

      give_it_some_time_to_finish_the_test_before_wiping_the_database
    end

    context "For a Pages::HomePage" do
      background do
        @page.type = 'Pages::HomePage'; @page.save
        @page = Page.find @page.id
      end

      scenario "Adding a locations map", :js do
        login @user

        visit page_settings_path @page
        within('tr.locations_map') { check :show_locations_map }

        click_on :back_to_the_page
        expect(page).to have_selector "#content #group-map-box-#{@page.id}"
      end

      scenario "Adding events", :js do
        @event = Group.everyone.events.create name: "Garden party",
          publish_on_global_website: true,
          start_at: 1.day.from_now

        login @user

        visit page_settings_path @page
        within 'tr.events' do
          within('.show_events') { check :show_events }
        end
        within '.box.events' do
          within('.global_website') { check :show_only_events_published_on_global_website }
        end

        click_on :back_to_the_page
        expect(page).to have_selector "#public-root-events-box"
        within "#public-root-events-box" do
          expect(page).to have_text "Garden party"
        end
      end

      scenario "Adding a teaser box", :js do
        login @user
        visit page_path @page

        create_a_new_teaser_box "My new teaser"

        click_on :edit
        edit_page_content "This is a short teaser text.\n\nAnd this is some more content."
        click_on :save
        wait_for_wysiwyg '.page_content'

        within('#header-nav') { click_on "example.com" }
        within '#content' do
          expect(page).to have_no_text "And this is some more content."
          expect(page).to have_text "My new teaser"
          expect(page).to have_text "This is a short teaser text."
        end
        within '#header-nav' do
          expect(page).to have_no_text "My new teaser"
        end
      end

      scenario "Adding a menu item", :js do
        login @user
        visit page_path @page

        create_a_new_menu_item "About us"
        click_on :edit
        edit_page_content "We are nice people."
        click_on :save
        wait_for_wysiwyg '.page_content'

        within('#header-nav') { expect(page).to have_text "About us" }

        sleep 10
        visit page_path(Page.find_by title: "About us")
        expect(page).to have_text "We are nice people"
      end

      scenario "Adding an officers box", :js do
        login @user
        visit page_path @page

        find('a#page_settings_button').click
        within('tr.officers') { check :show_officers }

        click_on :back_to_the_page
        expect(page).to have_selector "#officers-box-for-#{@page.id}"
        within "#officers-box-for-#{@page.id}" do
          expect(page).to have_text t :admins
          expect(page).to have_text @user.title
        end
        give_it_some_time_to_finish_the_test_before_wiping_the_database
      end

    end
  end

  scenario "Creating a new home page", :js do
    @corporation = create :corporation
    @user = create :user_with_account
    @corporation.admins << @user

    login @user
    visit home_pages_path

    click_on :create_new_home_page
    enter_in_place 'tr.page_title', 'Welcome to example.org!'
    enter_in_place 'tr.page_domain', 'example.org'

    click_on :back_to_the_page
    expect(page).to have_text "example.org"

    # Destroying the home page within the first ten minutes
    # should work.
    within '.box.first' do
      find('.destroy_page.btn').click
    end

    # This should redirect to the root#index.
    within "#content" do
      expect(page).to have_text Page.intranet_root.title
    end

    # We need this to prevent ajax requests after via scroll-to-load
    # after leaving the spec.
    visit root_path(scroll_to_load: 'false')
    within "#content" do
      expect(page).to have_text Page.intranet_root.title
    end
  end
end