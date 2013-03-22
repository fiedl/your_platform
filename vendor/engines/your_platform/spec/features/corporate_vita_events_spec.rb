# -*- coding: utf-8 -*-
require 'spec_helper'

feature 'Events in the Corporate Vita:', js: true do

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

  scenario 'assigning a new event' do #, driver: :selenium do
    visit user_path(user)
    within "#corporate_vita" do
      click_on_empty_event_place_holder
      fill_in_event_name "A thrilling new event\n"

      page.should have_no_selector('.status_event_by_name form input')
      page.should have_selector('.status_event_by_name', visible: true, text: "A thrilling new event")
    end
  end

  def click_on_empty_event_place_holder
    find("span.status_event_by_name", text: "—").click
    # which is the place holder for the not given event name of the in place editor.
  end

  def fill_in_event_name( event_name )
    fill_in :event_by_name, with: event_name
  end

  context "for an existing event:" do
    given(:event) { Event.create(name: "Fancy Event", start_at: 1.hour.from_now) }
    before { corporation.child_events << event }
    scenario "assigning the existing event" do #, driver: :selenium do
      visit user_path(user)
      within '#corporate_vita' do
        click_on_empty_event_place_holder
        fill_in_event_name "Fancy Event\n"
      end
      membership.reload.event.should == event
    end
  end

  #    context "for an already assigned event:" do
  #      before do
  #        @event = @membership.create_event( name: "Fancy Event", start_at: 1.hour.from_now )
  #        wait
  #      end
  #      scenario 'unassigning events' do
  #        visit user_path @user
  #        within '#corporate_vita' do
  #          page.should have_content "Fancy Event"
  #          find('.status_event_by_name', text: "Fancy Event").click
  #          fill_in_event_name "\n"
  #          page.should have_selector('.status_event_by_name', visible: true)
  #          page.should_not have_selector('.status_event_by_name', visible: true, text: "Fancy Event")
  #        end
  #        @user.upcoming_events.should_not include @event
  #      end
  #    end



end


