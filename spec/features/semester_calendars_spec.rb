require 'spec_helper'

feature "Semester Calendars", :js do
  include SessionSteps

  background do
    @corporation = create :corporation
    @office = @corporation.officers_parent.child_groups.create name: "Secretary"
    @officer = create :user_with_account
    @office.assign_user @officer

    @semester_calendar = @corporation.semester_calendars.create year: Time.zone.now.year, term: :summer_term
  end

  scenario "Adding an event" do
    login @officer
    visit edit_semester_calendar_path(@semester_calendar)

    click_on :add_event
    find('.event_starts_at input').set I18n.localize(Time.zone.now.change(month: 7).to_time)
    find('.event_name input').set "My new event"
    find('.event_location input').set "adH"

    click_on :save
    page.should have_no_text t(:add_event)

    @event = Event.last
    @event.title.should == "My new event"

    page.should have_text "My new event"
  end
end