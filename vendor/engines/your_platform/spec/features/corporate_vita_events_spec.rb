# -*- coding: utf-8 -*-
require 'spec_helper'

feature 'Events in the Corporate Vita:', js: true do
  include SessionSteps

  given(:corporation) { create :corporation_with_status_groups }
  given(:status_group) { corporation.child_groups.first }
  given(:user) do
    user = create :user
    status_group.assign_user user
    user
  end
  given(:membership) { StatusGroupMembership.now_and_in_the_past.find_by_user_and_group( user, status_group ) }

  specify 'prerequisites should be fulfilled' do
    user.should be_kind_of User
    user.corporations.should include corporation
    corporation.should be_kind_of Group
    corporation.should be_kind_of Corporation
    user.groups.should include status_group
    status_group.should be_kind_of Group
  end

  scenario 'assigning a new event' do
    login(:admin)
    visit user_path(user) 
    within section_selector do
      click_edit_button
      fill_in_event_name "A thrilling new event"
      click_save_button

      page.should have_no_selector('.status_event_by_name form input')
      page.should have_selector('.status_event_by_name', visible: true, text: "A thrilling new event")
    end
    wait_for_ajax_to_complete
  end

  def section_selector
    "div.section.corporate_vita"
  end

  def click_edit_button
    click_on I18n.t(:edit)
  end

  def click_save_button
    click_on I18n.t(:save)
    page.should have_selector('.save_button', visible: true)
    page.should have_no_selector('.modal_bg', visible: true)
  end

  def click_on_empty_event_place_holder
    find("span.status_event_by_name", text: "—").click
    # which is the place holder for the not given event name of the in place editor.
  end

  def fill_in_event_name( event_name )
    fill_in :event_by_name, with: event_name
  end

  def wait_for_ajax_to_complete
    # Even though capybara is pretty suffisticated regarding its mechanism
    # to wait for requests to be finished. But sometimes, one has to make sure, 
    # manually, that all asynchronous requests are finished before stepping
    # to the next test. Before every test, the DatabaseCleaner wipes the
    # database. Thus, if an ajax requests is not finished, it will hit the 
    # database after wiping, which leads to very unforseeable errors.
    sleep 2
  end

  given(:reloaded_membership) do
    sleep 1 # give the API some time to write to the database
    StatusGroupMembership.now_and_in_the_past.find(membership.id)
  end

  context "for an existing event:" do
    given(:event) { Event.create(name: "Fancy Event", start_at: 1.hour.from_now) }
    before { corporation.child_events << event }

    scenario "assigning the existing event" do
      login(:admin)
      visit user_path(user)
      within section_selector do
        click_edit_button
        fill_in_event_name "Fancy Event"
        click_save_button

        page.should have_no_selector "input"
      end
      reloaded_membership.event.should == event
    end

    context "for an already assigned event:" do
      before { membership.event = event; membership.save }
      scenario 'unassigning events' do
        login(:admin)
        visit user_path(user)
        within section_selector do
          page.should have_content "Fancy Event"

          click_edit_button
          fill_in_event_name ""
          click_save_button

          page.should have_selector('.status_event_by_name', visible: true)
          page.should have_no_selector('.status_event_by_name', visible: true, text: "Fancy Event")
        end
        reloaded_membership.event.should == nil
      end
    end
  end

end


