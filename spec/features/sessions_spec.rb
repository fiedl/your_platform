require 'spec_helper'


feature 'Sessions' do
  include SessionSteps
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
        within "#content_area" do
          fill_in 'user_account_login', with: @user.name
          fill_in 'user_account_password', with: @password
          click_on :login
        end
        page.should have_content(@user.name)
        page.should have_content(I18n.t(:logout))
      end

      it 'should allow to create a new session with email' do
        within "#content_area" do
          fill_in 'user_account_login', with: @user.email
          fill_in 'user_account_password', with: @password
          click_on :login
        end
        page.should have_content(@user.name)
        page.should have_content(I18n.t(:logout))
      end

      it 'should allow to create a new session with alias' do
        within "#content_area" do
          fill_in 'user_account_login', with: @user.alias
          fill_in 'user_account_password', with: @password
          click_on :login
        end
        page.should have_content(@user.name)
        page.should have_content(I18n.t(:logout))
      end
    end

    describe 'filling in an invalid password' do
      before do
        @user = create(:user_with_account)
        within "#content_area" do
          fill_in 'user_account_login', with: @user.name
          fill_in 'user_account_password', with: 'invalid'
          click_on :login
        end
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
        within "#content_area" do
          fill_in 'user_account_login', with: 'invalid'
          fill_in 'user_account_password', with: @password
          click_on :login
        end
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
        email_text.should include(reset_password_path)
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

      it { should have_field('password') }
      it { should have_field('user_account_password_confirmation') }
      it { should have_field(I18n.t(:i_agree_i_do_not_use_the_same_password_on_other_services), :checked => false) }
      it { should have_button(I18n.t(:submit_changed_password), visible: false) }

      describe 'but without matching password confirmation' do
        before do
          @password = 'fordprefecthasanawesometowel!'

          fill_in 'password', with: @password
          fill_in 'user_account_password_confirmation', with: 'invalid'
        end

        it { should have_button(I18n.t('submit_changed_password'), visible: false) }
      end
    end

    describe 'with invalid password reset token' do
      before do
        visit edit_user_account_password_path
      end

      it 'should redirect to the sign in path' do
        current_path.should == new_user_account_session_path
      end

      it 'should display an error message' do
        page.should have_text t('devise.passwords.user_account.no_token')
      end
    end

  end
end
