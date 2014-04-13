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

    it 'should allow to create a new session' do
      @user = create(:user)
      @user.create_account = true
      @user.save
      @password = @user.account.password

      fill_in 'user_account_login', with: @user.name
      fill_in 'user_account_password', with: @password
      
      Timeout::timeout(30) do
        click_button I18n.t(:login)
      end
      page.should have_content(@user.name)
      page.should have_content(I18n.t(:logout))
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
end
