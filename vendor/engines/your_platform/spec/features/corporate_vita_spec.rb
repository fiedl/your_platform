# -*- coding: utf-8 -*-
require 'spec_helper'

feature 'Corporate Vita', js: true do
  include SessionSteps

  background do
    @user = create( :user_with_account )
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

      login(:admin)
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

        # run the first workflow
        within '.box.first' do
          click_on I18n.t(:change_status)
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
        within '.box.first' do
          click_on I18n.t(:change_status)
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
          end

          # enter new date of joining and press enter to save.
          # then check if the date has been changed in the database.
          within first '.best_in_place.status_group_date_of_joining' do
            @new_date = 10.days.ago
            fill_in "created_at_date_formatted", with: (I18n.localize(@new_date) + "\n")
            @membership.reload.created_at.to_date.should == @new_date
          end            

          # TODO: Neues Datum eintragen und bearbeiten abschließen.
          # TODO: Vergleichen, ob das Datum auch in die Datenbank gespeichert wurde.

        end
      end
    end
  end

end

