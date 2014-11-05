require 'spec_helper'

feature 'Change Password', :js => true do
  include SessionSteps

  subject { page }

  describe 'when visiting the own profile' do
    background do
      @user = create(:user_with_account)
      @current_password = @user.account.password
      login(@user)
      visit user_path(@user)
      within('.box.section.access') do

        click_on I18n.t(:edit)
      end
    end

    it { should have_link I18n.t(:change_password) }

    describe "and clicking #{I18n.t(:change_password)}" do
      background do
        click_on I18n.t(:change_password)
      end

      it { should have_field('user_account_password') }
      it { should have_field('user_account_password_confirmation') }
      it { should have_field('user_account_current_password') }
      it { should have_field(I18n.t(:i_agree_i_do_not_use_the_same_password_on_other_services), :checked => false) }
      it { should have_button(I18n.t(:submit_changed_password)) }

      describe 'and matching password and confirmation' do
        before do
          @password = 'Password123'
          fill_in 'user_account_password', with: @password
          fill_in 'user_account_password_confirmation', with: @password
        end

        describe 'and correct current password' do
          before do
            fill_in 'user_account_current_password', with: @current_password
          end

          describe 'and having checked the agreement, after clicking submit' do
            before do
              find('label', :text => I18n.t(:i_agree_i_do_not_use_the_same_password_on_other_services)).set(true)
              click_button I18n.t(:submit_changed_password)
            end
            it { should have_notice(I18n.t('devise.registrations.updated')) }
          end

          describe 'but not having checked the agreement' do
            before do
              #page.save_and_open_page('~/blubb')
              page.save_screenshot('~/blubb')
              #click_button I18n.t(:submit_changed_password)
            end

            it { should_not have_notice(I18n.t('devise.registrations.updated')) }
            it { should have_button(I18n.t('submit_changed_password'), disabled: true) }
          end

        end

        describe 'but wrong current password' do
          before do
            fill_in 'user_account_current_password', with: 'invalid'
            click_button I18n.t(:submit_changed_password)
          end

          it { should have_content(I18n.t('errors.messages.not_saved.one', resource:'user account')) }

        end

      end

      describe 'but without matching password confirmation' do
        before do
          @password = 'Password123'
          fill_in 'user_account_password', with: @password
          fill_in 'user_account_password_confirmation', with: 'invalid'
          fill_in 'user_account_current_password', with: @current_password
          click_button I18n.t(:submit_changed_password)
        end

        it { should have_validation_errors }
        it { should have_content(I18n.t('errors.messages.not_saved.one', resource:'user account')) }
      end

    end

  end

  describe 'when visiting the profile of another user' do
    background do
      @user = create(:user_with_account)
      login(:user)
      visit user_path(@user)
    end

    it { should_not have_link(I18n.t(:change_password))}
  end

  describe 'when visiting the profile of another user as admin' do
    background do
      @user = create(:user_with_account)
      login(:admin)
      visit user_path(@user)
    end

    it { should_not have_link(I18n.t(:change_password))}
  end
end