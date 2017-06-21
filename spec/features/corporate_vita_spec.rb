# -*- coding: utf-8 -*-
require 'spec_helper'

feature 'Corporate Vita', js: true do
  include SessionSteps

  background do
    @user = create( :user_with_account )
    @corporation = create( :corporation_with_status_groups )
    @status_groups = @corporation.status_groups

    # In order to create a clean workflow state after creating the corporations:
    Workflow.destroy_all
    Workflow.find_or_create_mark_as_deceased_workflow
  end

  pending "as local admin"

  describe 'as global admin:' do

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

      #login(:local_admin, of: @corporation)
      login :global_admin

      visit user_path( @user )
    end

    specify "prelims" do
      @user.workflows_by_corporation.should == {
        @corporation.name => [@first_promotion_workflow]
      }
      User.last.should be_global_admin
      User.last.can?(:execute, @first_promotion_workflow).should be true
    end

    describe 'viewing the user page' do
      subject { page } # user profile page
      it 'should list the status group the user is a member of' do
        page.should have_content @status_groups.first.name
        page.should have_no_content @status_groups.last.name
      end
    end

    describe 'promoting users (i.e. change their status)' do
      it 'should be possible to promote users' do

        # run the first workflow
        within '.box.first' do
          click_on I18n.t(:change_status)
          click_on @first_promotion_workflow.name
        end

        wait_for_ajax; wait_for_ajax; wait_for_ajax;

        within '#corporate_vita' do
          page.should have_content @status_groups.first.name
          page.should have_content @status_groups.second.name
          page.should have_no_content @status_groups.last.name

          # check this to avoid the double listing bug (sf 2013-01-24)
          page.should have_selector( 'a', count: 2 )

        end

        # run the second workflow
        within '.box.first' do
          click_on I18n.t(:change_status)
          click_on @second_promotion_workflow.name
        end

        wait_for_ajax; wait_for_ajax; wait_for_ajax;

        within first '.section.corporate_vita' do
          page.should have_content @status_groups.first.name
          page.should have_content @status_groups.second.name
          page.should have_content @status_groups.last.name
        end

      end

    end

    describe 'change the date of promotion afterwards' do
      before do
        @first_promotion_workflow.execute( user_id: @user.id )
        @membership = Membership.now_and_in_the_past.find_by_user_and_group( @user, @status_groups.first )
        visit user_path( @user )
      end

      it 'should be possible to change the date' do
        within('#corporate_vita') do

          @valid_from_formatted = I18n.localize @membership.valid_from.in_time_zone(@user.time_zone).to_date

          page.should have_content @valid_from_formatted

          # activate inplace editing of the date_field
          first('.best_in_place.status_group_date_of_joining').click

          within first '.best_in_place.status_group_date_of_joining' do
            page.should have_field 'valid_from_localized_date', with: @valid_from_formatted
          end

          @new_date = 10.days.ago.to_date
          fill_in "valid_from_localized_date", with: I18n.localize(@new_date)

          page.should have_no_selector("input")
          page.should have_content I18n.localize(@new_date)

          wait_until { Membership.now_and_in_the_past.find(@membership.id).valid_from.to_date != Time.zone.now.to_date }
          Membership.now_and_in_the_past.find(@membership.id).valid_from.to_date.should == @new_date
        end
      end
    end
  end

  describe 'as normal user visiting the own profile:' do

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

      login(@user)
      visit user_path( @user )
    end

    describe 'viewing the user page' do
      subject { page } # user profile page
      it 'should list the status group the user is a member of' do
        page.should have_content @status_groups.first.name
        page.should have_no_content @status_groups.last.name
      end
    end

    describe 'promoting himself (i.e. change his status)' do
      it 'should not be possible to promote himself' do
        # run the second workflow
        within '.box.first' do
          page.should have_no_button I18n.t(:change_status)
        end
      end
    end

    describe 'change the date of promotion afterwards' do
      before do
        @first_promotion_workflow.execute( user_id: @user.id )
        @membership = Membership.now_and_in_the_past.find_by_user_and_group( @user, @status_groups.first )
        visit user_path( @user )
      end

      it 'should be possible to change the date' do
        within('#corporate_vita') do

          @valid_from_formatted = I18n.localize @membership.valid_from.in_time_zone(@user.time_zone).to_date

          page.should have_content @valid_from_formatted

          # activate inplace editing of the date_field
          first('.best_in_place.status_group_date_of_joining').click

          within first '.best_in_place.status_group_date_of_joining' do
            page.should have_field 'valid_from_localized_date', with: @valid_from_formatted
          end

          @new_date = 10.days.ago.to_date
          fill_in "valid_from_localized_date", with: I18n.localize(@new_date)

          page.should have_no_selector("input")
          page.should have_content I18n.localize(@new_date)

          wait_until { Membership.now_and_in_the_past.find(@membership.id).valid_from.to_date != Time.zone.now.to_date }
          Membership.now_and_in_the_past.find(@membership.id).valid_from.to_date.should == @new_date

        end
      end
    end

    describe 'if the date of the promotion was erroneously changed to a date in the future' do
      before do
        @first_promotion_workflow.execute( user_id: @user.id )
        @membership = Membership.now_and_in_the_past.find_by_user_and_group( @user, @status_groups.first )
        @membership.valid_from = 1.day.from_now
        visit user_path( @user )
      end

      it 'should still be visible in the profile' do
        page.should have_content @status_groups.first.name
      end
    end
  end


  describe 'as different user:' do

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

      login(:user)
      visit user_path( @user )
    end

    describe 'viewing the user page' do
      subject { page } # user profile page
      it 'should list the status group the user is a member of' do
        page.should have_content @status_groups.first.name
        page.should have_no_content @status_groups.last.name
      end
    end

    describe 'promoting users (i.e. change their status)' do
      it 'should not be possible to promote users' do

        # run the first workflow
        within '.box.first' do
          page.should have_no_content I18n.t(:change_status)
        end
      end

    end

    describe 'change the date of promotion afterwards' do
      before do
        @first_promotion_workflow.execute( user_id: @user.id )
        @membership = Membership.now_and_in_the_past.find_by_user_and_group( @user, @status_groups.first )
        visit user_path( @user )
      end

      it 'should not be possible to change the date' do
        within('#corporate_vita') do

          @valid_from_formatted = I18n.localize @membership.valid_from.to_date

          #page.should have_content @created_at_formatted #why does this fail?

          # activate inplace editing of the date_field
          page.should have_no_selector('.best_in_place.status_group_date_of_joining')
        end
      end
    end
  end
end

