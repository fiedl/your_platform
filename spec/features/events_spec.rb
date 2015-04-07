require 'spec_helper'

feature "Events" do
  include SessionSteps
  
  before do
    @user = create(:user_with_account)
    @group = create(:group)
    @event = @group.child_events.create name: "Graduation Celebration", start_at: 1.day.from_now
    
    @other_group = create(:group)
    @other_event = @other_group.child_events.create name: "Other Event", start_at: 2.days.from_now
    
    # Apparently, the callbacks need time. If we don't sleep here, `ActiveRecord::RecordNotFound`
    # is raised. In practice, we use an error handler in the EventsController due to this inconvenience.
    # 
    # This does still exist in Rails 4.
    # TODO: Check if this problem still exists when migrating to Rails 5.
    #
    @event.wait_for_me_to_exist
  end
  
  context "for the public internet" do
    before do
      @event.update_attribute :publish_on_local_website, true
      @other_event.update_attribute :publish_on_global_website, true
    end
    
    scenario "looking at the global public events html feed" do
      visit public_events_path
      page.should have_text @other_event.name
      page.should have_no_text @event.name
    end
    
    specify "the public feed should allow to limit the number of events" do
      Event.destroy_all
      @event1 = @group.child_events.create name: 'event 1', publish_on_global_website: true, start_at: 1.day.from_now
      @event2 = @group.child_events.create name: 'event 2', publish_on_global_website: true, start_at: 2.day.from_now
      @event3 = @group.child_events.create name: 'event 3', publish_on_global_website: true, start_at: 3.day.from_now
      @event4 = @group.child_events.create name: 'event 4', publish_on_global_website: true, start_at: 4.day.from_now
      
      visit public_events_path(limit: 3)
      page.should have_text @event1.name
      page.should have_text @event2.name
      page.should have_text @event3.name
      page.should have_no_text @event4.name
    end
    
    specify "the public feed should display the events ordered by the start time" do
      Event.destroy_all
      @event4 = @group.child_events.create name: 'event 4', publish_on_global_website: true, start_at: 4.day.from_now
      @event2 = @group.child_events.create name: 'event 2', publish_on_global_website: true, start_at: 2.day.from_now
      @event3 = @group.child_events.create name: 'event 3', publish_on_global_website: true, start_at: 3.day.from_now
      @event1 = @group.child_events.create name: 'event 1', publish_on_global_website: true, start_at: 1.day.from_now
      
      visit public_events_path(limit: 3)
      page.body.should =~ /#{@event1.name}.*#{@event2.name}.*#{@event3.name}/m  # `/m` allowes newlines. 
    end
    
    scenario "looking at the local public events html feed" do
      visit group_events_public_path(@group)
      page.should have_no_text @other_event.name
      page.should have_text @event.name
    end

    specify "the local feed should allow to limit the number of events" do
      Event.destroy_all
      @event1 = @group.child_events.create name: 'event 1', publish_on_local_website: true, start_at: 1.day.from_now
      @event2 = @group.child_events.create name: 'event 2', publish_on_local_website: true, start_at: 2.day.from_now
      @event3 = @group.child_events.create name: 'event 3', publish_on_local_website: true, start_at: 3.day.from_now
      @event4 = @group.child_events.create name: 'event 4', publish_on_local_website: true, start_at: 4.day.from_now
      
      visit group_events_public_path(@group, limit: 3)
      page.should have_text @event1.name
      page.should have_text @event2.name
      page.should have_text @event3.name
      page.should have_no_text @event4.name
    end
    
    scenario "loading the global public event ics feed" do
      visit public_events_path format: 'ics'
      page.should have_text 'BEGIN:VCALENDAR'
      page.should have_text @other_event.name
      page.should have_no_text @event.name
    end
    
    scenario "loading the local public event ics feed" do
      visit group_events_public_path @group, format: 'ics'
      page.should have_text 'BEGIN:VCALENDAR'
      page.should have_no_text @other_event.name
      page.should have_text @event.name
    end
  end
  
  context "for users" do
    background { login @user }
    context "being no member of the group the event belongs to" do
      
      scenario "visiting the start page" do
        visit root_path
        page.should have_no_text I18n.t(:events)
        page.should have_no_selector '.upcoming_events'
      end
      
    end
    context "being member of the group the event belongs to" do
      background { @group.assign_user @user, at: 1.year.ago }
      
      scenario "visiting the start page" do
        visit root_path
        page.should have_text I18n.t(:events)
        page.should have_selector '.upcoming_events'
        within '.box.upcoming_events' do
          page.should have_text @event.name
          page.should have_text I18n.localize(@event.start_at.to_date, format: :long)
          page.should have_text @event.group.name
          page.should have_no_text @other_event.name
          page.should have_text I18n.t(:show_all)
          page.should have_selector '#ics_abo'
          page.should have_no_selector '#create_event'
          page.should have_no_text I18n.t('date.to')
        end
      end
      
      scenario "visiting the start page with several-day events" do
        @event.start_at = 1.day.ago
        @event.end_at = @event.start_at + 3.days
        @event.save
        
        visit root_path
        page.should have_text I18n.t(:events)
        page.should have_selector '.upcoming_events'
        within '.box.upcoming_events' do
          page.should have_text @event.name
          page.should have_text I18n.t('date.to')
          page.should have_text @event.start_at.day.to_s
          page.should have_text I18n.localize(@event.end_at.to_date, format: :long)
          page.should have_text @event.group.name
          page.should have_no_text @other_event.name
        end
      end
      
      scenario "showing event details" do
        visit root_path
        within('.box.upcoming_events') { click_on @event.name }
        page.should have_text I18n.t :description
        page.should have_text I18n.t :start_at
        page.should have_text I18n.t :end_at
        page.should have_no_text I18n.t :optional
        page.should have_text I18n.t :contact_people
        page.should have_text I18n.t :attendees
        page.should have_no_text I18n.t :publish
        page.should have_no_selector '.best_in_place'
        page.should have_selector '#join_event'
        page.should have_no_selector '#toggle_invite'
      end
      
      scenario "joining an event", js: true do
        visit root_path
        within('.box.upcoming_events') { click_on @event.name }
        page.should have_no_selector '.member_avatar'
        page.should have_selector '#join_event', visible: true
        page.should have_no_selector '#leave_event', visible: true
        find('#join_event').click
        page.should have_selector '.member_avatar'
        page.should have_no_selector '#join_event', visible: true
        page.should have_selector '#leave_event', visible: true
        find('#leave_event').click
        page.should have_selector '#join_event', visible: true
        page.should have_no_selector '#leave_event', visible: true
        page.should have_no_selector '.member_avatar'
      end
      
      scenario "joining an event via get", :js do
        visit event_join_via_get_path(@event, email_confirm: true)
        page.should have_no_text 'Unauthorisierter Zugang'
        page.should have_selector '.member_avatar'
        page.should have_no_selector '#join_event', visible: true
        page.should have_selector '#leave_event', visible: true
      end
      
      scenario "exporting an event" do
        visit root_path
        within('.box.upcoming_events') { click_on @event.name }
        find('#ics_export').click
        page.should have_text 'BEGIN:VCALENDAR'
        page.should have_text @event.name
      end
      
      scenario "listing all events" do
        visit root_path
        within('.box.upcoming_events') { click_on I18n.t(:show_all) }
        page.should have_text I18n.t :my_events
        page.should have_text @event.name
        page.should have_no_text @other_event.name
        
        click_on @event.name
        page.should have_text I18n.t :description
        page.should have_text I18n.t :start_at
        page.should have_text I18n.t :end_at
      end
      
      scenario "exporting personal calendar" do
        visit root_path
        within('.box.upcoming_events') { find('#ics_abo').click }
        page.should have_text 'BEGIN:VCALENDAR'
        page.should have_text @event.name
        page.should have_no_text @other_event.name
      end
      
      scenario "looking at upcoming group events" do
        visit group_path(@group)
        within('.box.upcoming_events') do
          page.should have_text @event.name
          page.should have_no_text @other_event.name
        end
      end
      
      scenario "exporting group events" do
        visit group_path(@group)
        within('.box.upcoming_events') { find('#ics_abo').click }
        page.should have_text 'BEGIN:VCALENDAR'
        page.should have_text @event.name
        page.should have_no_text @other_event.name
      end
    end
  end

  context "for officers", js: true do
    background do 
      @group.officers_parent.child_groups.create(name: 'President').assign_user @user, at: 1.hour.ago
      login @user
    end
    
    scenario "creating an event from the root page" do
      visit root_path
      find('#create_event').click
      page.should have_text 'Bezeichnung der Veranstaltung hier eingeben'
    end

    scenario "creating an event from a group page" do
      visit group_path(@group)
      find('#create_event').click
      page.should have_text 'Bezeichnung der Veranstaltung hier eingeben'
    end
    
    if ENV['CI'] != 'travis'  # this keeps failing on travis
      scenario "editing an event" do
        sleep 3  # to give the database some time after creating the event.
        visit event_path(@event)
        within('.box.first h1') do
          find('.best_in_place').click
          find('input').set "My cool new event\n"
          page.should have_no_selector 'input'
          page.should have_text "My cool new event"
      
          # # This works in practice, but not in the test. :(
          # # TODO: Fix this test:
          # within('.vertical_menu') { page.should have_text "My cool new event" }
          # within('#breadcrumb') { page.should have_text "My cool new event" }
        end
      end
    end
    
    scenario "editing an event, pt. 2" do
      visit event_path(@event)
      within 'tr.description' do
        find('.best_in_place').click
        find('textarea').set "My new event description."
        # tab \t switches to the next input field. But the event handlers are not triggered as expected.
        # TODO: Fix this feature.
      end
      
      within('tr.start_at') { find('.best_in_place').click }
      page.should have_selector '#ui-datepicker-div', visible: true
      click_on 'Fertig'  # closes datepicker
      page.should have_no_selector '#ui-datepicker-div', visible: true
      
      within 'tr.contact_people' do
        find('.best_in_place').click
        
        @other_user = create(:user)
        page.execute_script "$('tr.contact_people * .best_in_place').trigger('edit')"  # to keep it open
        page.execute_script "$('tr.contact_people * .best_in_place input').val('#{@other_user.last_name}')"
        page.execute_script "$('tr.contact_people * .best_in_place input').trigger('focus')"
        page.execute_script "$('tr.contact_people * .best_in_place input').trigger('keydown')"
      end
      
      # # TODO: Fix this spec.
      # # When I break at this point and open this state in a browser, the auto-complete menu will open.
      # # But I fail to simulate this in this test.
      # #
      # selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains("#{@other_user.title}")}
      # page.should have_selector('ul.ui-autocomplete li.ui-menu-item a')
      # page.execute_script %Q{ $('#{selector}').trigger('mouseenter').click() }
      # 
      # page.should have_text @other_user.name  # auto completion menu
    end
    
    scenario "editing an event, pt. 3" do
      visit event_path(@event)
      within('tr.publish_on_local_website') { find('select').click }
      within('tr.publish_on_global_website') { find('select').click }
    end

    scenario "inviting group members" do
      visit event_path(@event)
      find('#toggle_invite').click
      page.should have_selector '#invitation_text', visible: true
      find('#test_invite').click
      find('#confirm_invite').click
      page.should have_no_selector '#invitation_text', visible: true
    end

  end
  
  describe "creating an event as officer of a local corporation (bug fix)", :js do
    # We had this issue:
    #
    #     Started POST "/events.json?group_id=12" for 2.242.197.85 at 2014-10-23 16:54:47 +0200
    #     Processing by EventsController#create as JSON
    #       Parameters: {"group_id"=>"12"}
    #       Rendered terms_of_use/_terms.html.haml (0.2ms)
    #     Completed 422 Unprocessable Entity in 9932.8ms
    #     
    #     ActiveRecord::RecordInvalid (Validation failed: Ancestor has already been taken).
    #
    # As it turned out, this has been caused by mysql locking issues, when callbacks
    # locked the event while adding attendees and contact_people groups.
    #
    background do
      @corporation = create :corporation_with_status_groups
      @corporation.status_groups.first.assign_user @user, at: 1.month.ago
      @president = @corporation.officers_parent.child_groups.create name: 'President'
      @president.assign_user @user, at: 5.days.ago
      @other_event = create :event
      @other_event.parent_groups << @corporation
    end
    scenario "creating an event as officer of a local corporation (bug fix)" do
      login @user
      visit root_path
      within('#create_event') { page.should have_text @corporation.name }

      find('#create_event').click
      page.should have_text 'Bezeichnung der Veranstaltung hier eingeben'
      within '.contact_people' do
        page.should have_text @user.title
      end
      
      @event = Event.last
      @event.id.should_not == @other_event.id
      @event.group.id.should == @corporation.id
      @event.contact_people.should include @user
    end
  end
  
end