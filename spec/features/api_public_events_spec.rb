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

end