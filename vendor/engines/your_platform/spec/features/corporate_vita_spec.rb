# -*- coding: utf-8 -*-
require 'spec_helper'

feature 'Corporate Vita', js: true do

  before do
    @user = create( :user )
    @corporation = create( :corporation_with_status_groups )
    @status_groups = @corporation.child_groups
  end

  describe "promotion workflows:" do

    background do
      @status_groups.first.assign_user @user

      @first_promotion_workflow = create( :promotion_workflow, name: 'First Promotion',
                                          :remove_from_group_id => @status_groups.first.id,
                                          :add_to_group_id => @status_groups.second.id )
      @first_promotion_workflow.parent_groups << @status_groups.first

      @second_promotion_workflow = create( :promotion_workflow, name: 'Second Promotion',
                                           :remove_from_group_id => @status_groups.second.id,
                                           :add_to_group_id => @status_groups.last.id )
      @second_promotion_workflow.parent_groups << @status_groups.second

      visit user_path( @user )
    end

    describe 'viewing the user page' do
      subject { page } # user profile page
      it 'should list the status group the user is a member of' do
        page.should have_content @status_groups.first.name
        page.should_not have_content @status_groups.last.name
      end
    end

    describe 'promoting users (i.e. change their status)' do
      it 'should be possible to promote users' do

        # enter edit mode of the first box
        find('.edit_button.first').click

        # run the first workflow
        within '#user_workflows' do
          click_on @first_promotion_workflow.name
        end

        within '#corporate_vita' do
          page.should have_content @status_groups.first.name
          page.should have_content @status_groups.second.name
          page.should_not have_content @status_groups.last.name

          # check this to avoid the double listing bug (sf 2013-01-24)
          page.should have_selector( 'a', count: 2 )

        end

        # run the second workflow
        find('.edit_button.first').click
        within '#user_workflows' do
          click_on @second_promotion_workflow.name
        end

        within first '.section.corporate_vita' do
          page.should have_content @status_groups.first.name
          page.should have_content @status_groups.second.name
          page.should have_content @status_groups.last.name
        end

      end

    end

    describe 'change the date of promation afterwards' do
      before do
        @first_promotion_workflow.execute( user_id: @user.id )
        @membership = UserGroupMembership.now_and_in_the_past.find_by_user_and_group( @user, @status_groups.first )
        visit user_path( @user )
      end

      it 'should be possible to change the date' do
        within('#corporate_vita') do

          @created_at_formatted = I18n.localize @membership.created_at.to_date

          page.should have_content @created_at_formatted

          # activate inplace editing of the date_field
          first('.best_in_place.status_group_date_of_joining').click

          within first '.best_in_place.status_group_date_of_joining' do
            find('input').value.should == @created_at_formatted

            # TODO: Neues Datum eintragen und bearbeiten abschließen.
            # TODO: Vergleichen, ob das Datum auch in die Datenbank gespeichert wurde.

          end

        end
      end
    end
  end

  describe 'assigning events:' do
    before do
      @status_group = @status_groups.first
      @status_group.assign_user @user
      @membership = StatusGroupMembership.now_and_in_the_past.find_by_user_and_group( @user, @status_group )
    end

    specify 'prerequisites should be fulfilled' do
      @user.should be_kind_of User
      @user.corporations.should include @corporation
      @corporation.should(be_kind_of(Group)) || @corporation.should(be_kind_of(Corporation))
      @user.groups.should include @status_groups.first
      @status_groups.first.should be_kind_of Group
    end

    subject { page }

    scenario 'assigning a new event' do
      visit user_path @user
      within '#corporate_vita' do
        find('.status_event_by_name').click
        fill_in_event_name("A thrilling new event")
        page.should_not have_selector('.status_event_by_name form input')
        page.should have_selector('.status_event_by_name', visible: true, text: "A thrilling new event")
      end
    end

#    context "for an existing event:" do
#      before do
#        @event = @user.corporations.first.events.create( name: "Fancy Event", start_at: 1.hour.from_now )
#      end
#      scenario 'assigning an existing event' do
#        visit user_path @user
#        within '#corporate_vita' do
#          find('.status_event_by_name').click
#          fill_in_event_name("Fancy Event\n")
#          @user.upcoming_events.first.should == @event
#        end
#      end
#    end
#
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

    def wait
      # apparently, poltergeist needs some time here.
      # If you have a better idea, please help!!
      sleep 2
    end

    def fill_in_event_name( event_name )
      wait
      page.find('.status_event_by_name form input', visible: true).set(event_name)
      wait
    end

  end

end

