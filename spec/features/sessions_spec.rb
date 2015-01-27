require 'spec_helper'


feature 'Sessions' do
  describe 'New Session Page' do  # to show the browser while testing, e.g. use `js: true`.
    
    before do
      visit sign_in_path
    end

    subject { page }

    describe 'Form elements' do
      it { should have_field('user_account_login') }
      it { should have_field('user_account_password') }
      it { should have_button I18n.t(:login) }
      it { should have_link I18n.t(:forgot_password) }
    end

    describe 'filling in a valid password' do
      before do
        @user = create(:user_with_account)
        @password = @user.account.password
      end

      it 'should allow to create a new session with user name' do
        fill_in 'user_account_login', with: @user.name
        fill_in 'user_account_password', with: @password

        Timeout::timeout(30) do
          click_button I18n.t(:login)
        end
        page.should have_content(@user.name)
        page.should have_content(I18n.t(:logout))
      end

      it 'should allow to create a new session with email' do
        fill_in 'user_account_login', with: @user.email
        fill_in 'user_account_password', with: @password

        Timeout::timeout(30) do
          click_button I18n.t(:login)
        end
        page.should have_content(@user.name)
        page.should have_content(I18n.t(:logout))
      end

      it 'should allow to create a new session with alias' do
        fill_in 'user_account_login', with: @user.alias
        fill_in 'user_account_password', with: @password

        Timeout::timeout(30) do
          click_button I18n.t(:login)
        end
        page.should have_content(@user.name)
        page.should have_content(I18n.t(:logout))
      end
    end

    describe 'filling in an invalid password' do
      before do
        @user = create(:user_with_account)
        fill_in 'user_account_login', with: @user.name
        fill_in 'user_account_password', with: 'invalid'
        click_button I18n.t(:login)
      end

      it { should have_no_content(@user.name) }
      it { should have_no_content(I18n.t(:logout)) }
      it { should have_warning I18n.t('devise.failure.invalid')}
    end

    describe 'filling in an invalid login name' do
      before do
        @user = create(:user)
        @user.create_account = true
        @user.save
        @password = @user.account.password
        fill_in 'user_account_login', with: 'invalid'
        fill_in 'user_account_password', with: @password
        click_button I18n.t(:login)
      end

      it { should have_no_content(@user.name) }
      it { should have_no_content(I18n.t(:logout)) }
      it { should have_content I18n.t('devise.failure.user_account.not_found_in_database')}
    end

  end

  describe 'Forgot Password Page' do
    before do
      visit new_user_account_password_path
    end

    subject { page }

    describe 'Form Elements' do
      it { should have_field('user_account_email')}
      it { should have_button(I18n.t(:submit_send_instructions))}
    end

    describe 'when filling in a valid email address' do
      before do
        ActionMailer::Base.deliveries.clear
        @user = create(:user)
        @user.create_account = true
        @user.save
        fill_in 'user_account_email', with: @user.email
        click_button I18n.t(:submit_send_instructions)
      end
      it 'should send an email' do
        ActionMailer::Base.deliveries.count.should be(1)
      end

      it "the email should be sent to the user's email address" do
        email = ActionMailer::Base.deliveries.last
        email.to.should include(@user.email)
      end

      it 'the email should contain a link to the password change page' do
        email_text = ActionMailer::Base.deliveries.last.to_s
        email_text.should include(edit_user_account_password_path)
      end

      it 'the email should contain the users name' do
        email_text = ActionMailer::Base.deliveries.last.to_s
        email_text.should include(@user.name)
      end
    end

    describe 'when filling in an invalid email address' do
      before do
        ActionMailer::Base.deliveries.clear
        fill_in 'user_account_email', with: 'invalid@example.org'
        click_button I18n.t(:submit_send_instructions)
      end

      it 'should send no email' do
        ActionMailer::Base.deliveries.count.should be(0)
      end
    end

  end

  describe 'Change Password Page', js: true do
    subject { page }

    describe 'with valid password reset token' do
      before do
        @user = create(:user_with_account)

        visit new_user_account_password_path
        fill_in 'user_account_email', with: @user.email
        click_button I18n.t(:submit_send_instructions)

        open_email(@user.email)
        click_first_link_in_email
      end

      it { should have_field('user_account_password') }
      it { should have_field('user_account_password_confirmation') }
      it { should have_field(I18n.t(:i_agree_i_do_not_use_the_same_password_on_other_services), :checked => false) }
      it { should have_button(I18n.t(:submit_changed_password), disabled: true) }

      describe 'and matching password and confirmation' do
        before do
          @password = 'fordprefecthasanawesometowel!'
          fill_in 'user_account_password', with: @password
          fill_in 'user_account_password_confirmation', with: @password
        end

        describe 'and having checked the agreement' do
          before do
            check(I18n.t(:i_agree_i_do_not_use_the_same_password_on_other_services))
          end

          it { should have_button(I18n.t('submit_changed_password')) }

          describe '- after clicking submit'do
            before do
              click_button I18n.t(:submit_changed_password)
            end

            it { should have_notice(I18n.t('devise.passwords.updated')) }
            it { should be_logged_in }
          end
        end

        describe 'but not having checked the agreement' do
          it { should have_button(I18n.t('submit_changed_password'), disabled: true) }
        end
      end

      describe 'and matching simple password and confirmation' do
        before do
          @password = 'Password123'
          fill_in 'user_account_password', with: @password
          fill_in 'user_account_password_confirmation', with: @password
          check(I18n.t(:i_agree_i_do_not_use_the_same_password_on_other_services))
        end

        it { should have_no_notice(I18n.t('devise.passwords.updated')) }
        it { should have_button(I18n.t('submit_changed_password'), disabled: true) }

      end

      describe 'but without matching password confirmation' do
        before do
          @password = 'fordprefecthasanawesometowel!'
          fill_in 'user_account_password', with: @password
          fill_in 'user_account_password_confirmation', with: 'invalid'
        end

        it { should have_button(I18n.t('submit_changed_password'), disabled: true) }
      end
    end

    describe 'with invalid password reset token' do
      before do
        visit edit_user_account_password_path
      end

      it 'should redirect to the sign in path' do
        current_path.should == new_user_account_session_path
      end
      it { should have_error_message I18n.t('devise.passwords.user_account.no_token')}
    end

  end
end
