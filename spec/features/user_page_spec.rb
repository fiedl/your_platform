# -*- coding: utf-8 -*-
require 'spec_helper'

feature 'User page', js: false do
  include SessionSteps

  subject { page }

  describe 'of a user with account' do

    background do
      User.destroy_all
      @user = create(:user_with_account)
    end


    describe 'when not signed in' do
      background do
        visit user_path(@user)
      end

      #it { should have_content "Access denied" }
    end

#  describe 'when signed in as the displayed user' do
#
#    background do
#      login(@user)
#      visit user_path(@user)
#    end
#
#
#  end

    describe 'when sigend in as admin' do

      background do
        login(:admin)
        visit user_path(@user)
      end

      it { should have_selector('h1', text: I18n.t(:about_myself)) }
      it { should have_selector('h1', text: I18n.t(:study_information)) }
      it { should have_selector('h1', text: I18n.t(:career_information)) }
      it { should have_selector('h1', text: I18n.t(:organizations)) }


      #it { should have_selector('title', text: 'Wingolfsplattform') } #can't get it to work on capybara 2.0

      scenario 'the section \'organizations\'', js: true do
        within('.box.section.organizations') do
          click_on I18n.t(:edit)
          page.should have_selector('a.add_button', visible: true)

          click_on I18n.t(:add)
          page.should have_selector('.profile_field')
          within first '.profile_field' do
            page.should have_selector('input[type=text]', count: 7)
          end

          find('.remove_button').click
          page.should_not have_selector('li')
        end
      end

      scenario 'the section \'Zugangsdaten\'', js: true do
        within('.box.section.access') do

          click_on I18n.t(:edit)
          page.should have_button(I18n.t(:delete_account) )

          expect { click_on I18n.t(:delete_account) }.to change(UserAccount, :count).by -1
        end
      end

    end
  end

  describe 'of a user without account' do
    let(:user) { create(:user) }

    describe 'when signed in as admin' do

      background do
        login(:admin)
        visit user_path(user)
      end

      scenario 'the section \'Zugangsdaten\'', js: true do
        within('.box.section.access') do
          page.should have_content(I18n.t :user_has_no_account)

          click_on I18n.t(:edit)
          page.should have_link(I18n.t(:create_account) )

          expect { click_on I18n.t(:create_account) }.to change(UserAccount, :count).by 1
          user.account should_not be_nil
        end
      end

    end
  end
end
