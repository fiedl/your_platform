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

    click_on :add_event_to_semester_calendar
    #find('.event_starts_at input').set I18n.localize(Time.zone.now.change(month: 7).to_time)
    page.all('.event_starts_at select')[0].find(:option, "01").select_option
    page.all('.event_starts_at select')[1].find(:option, "07").select_option
    page.all('.event_starts_at select')[2].find(:option, Time.zone.now.year.to_s).select_option
    page.all('.event_starts_at select')[3].find(:option, "20").select_option
    page.all('.event_starts_at select')[4].find(:option, "15").select_option

    find('.event_name input').set "My new event"
    find('.event_location input').set "adH"

    click_on :save
    page.should have_no_text t(:add_event_to_semester_calendar)

    @event = Event.last
    @event.title.should == "My new event"
    @event.contact_people.to_a.should == [@officer]

    page.should have_text "My new event"
  end

  if ENV['CI'] != 'travis'  # they do not support uploads
    scenario "Uploading a pdf" do
      login @officer
      visit semester_calendar_path(@semester_calendar)

      within "#attachments.semester_calendar_pdf" do
        drop_attachment_in_drop_field 'pdf-upload.pdf'
      end
      within ".box.semester_calendar_pdf" do
        page.should have_no_text I18n.t(:drop_pdf_here)
        page.should have_text I18n.t(:uploading_files)
        page.should have_no_text I18n.t(:uploading_files)
        page.should have_text I18n.t(:files_have_been_uploaded)
        page.should have_no_text I18n.t(:files_have_been_uploaded)

        # There's no problem when trying it out in a browser.
        # But in capybara, it does not work :(
        # # sleep 15 # as backend processing takes some time.
        # # page.should have_text I18n.t(:uploaded_at)
      end
      @semester_calendar.attachments.first.pdf?.should be_true
    end
  end
end