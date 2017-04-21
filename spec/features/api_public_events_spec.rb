require 'spec_helper'

feature "Public api for events" do

  background do
    @group = create :group

    @local_event = @group.events.create name: "Local event", publish_on_local_website: true
    @global_event = @group.events.create name: "Global event", publish_on_global_website: true
    @private_event = @group.events.create name: "Private event"
  end

  scenario "GET /api/v1/public/events" do
    visit "/api/v1/public/events.json"

    page.should have_text "Global event"
    page.should have_no_text "Local event"
    page.should have_no_text "Private event"

    page.should have_text @global_event.url
  end

  scenario "GET /api/v1/public/groups/123/events" do
    visit "/api/v1/public/groups/#{@group.id}/events.json"

    page.should have_no_text "Global event"
    page.should have_text "Local event"
    page.should have_no_text "Private event"
  end

  scenario "GET /api/v1/public/events?limit=1" do
    @past_event = create :event, start_at: 2.days.ago, end_at: nil, publish_on_global_website: true
    @upcoming_events = [
      create(:event, start_at: 1.day.from_now, end_at: nil, publish_on_global_website: true),
      create(:event, start_at: 2.days.from_now, end_at: nil, publish_on_global_website: true)
    ]

    visit "/api/v1/public/events?limit=1"

    page.should have_no_text @past_event.name
    page.should have_text @upcoming_events.first.name
    page.should have_no_text @upcoming_events.last.name
  end

  scenario "GET /api/v1/public/events?year=2006" do
    @event_2006 = create :event, start_at: Time.zone.now.change(year: 2006), publish_on_global_website: true
    @other_event = create :event, start_at: 2.days.ago, publish_on_global_website: true

    visit "/api/v1/public/events?year=2006"

    page.should have_no_text @other_event.name
    page.should have_text @event_2006.name
  end

  scenario "GET /api/v1/public/events?year=2006&term=winter_term" do
    @event_summer_2006 = create :event, start_at: Time.zone.now.change(year: 2006, month: 7), publish_on_global_website: true
    @event_winter_2006 = create :event, start_at: Time.zone.now.change(year: 2006, month: 12), publish_on_global_website: true
    @event_winter_2006_2007 = create :event, start_at: Time.zone.now.change(year: 2007, month: 1), publish_on_global_website: true
    @event_winter_2010 = create :event, start_at: Time.zone.now.change(year: 2010, month: 12), publish_on_global_website: true

    visit "/api/v1/public/events?year=2006&term=winter_term"

    page.should have_text @event_winter_2006.name
    page.should have_text @event_winter_2006_2007.name
    page.should have_no_text @event_summer_2006.name
    page.should have_no_text @event_winter_2010.name
  end



end