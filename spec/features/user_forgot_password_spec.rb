require 'spec_helper'

feature "UserForgotPassword" do
  include SessionSteps

  before do
    @user = User.create( first_name: "John", last_name: "Doe", email: "j.doe@example.com", :alias => "j.doe",
                         create_account: true )
  end

  context "for admins" do
    before { login(:admin) }

    describe "Profile Page" do

      it "should contain the send-new-password button" do
        visit user_path( @user )
        page.should have_button I18n.t( :send_new_password )
      end
    end

    describe "Send New Password Action" do

      def send_new_password
        visit user_path( @user )
        click_on I18n.t( :send_new_password )
      end

      before do
        send_new_password
      end

      it "should send a flash message" do
        page.should have_content( I18n.t( :new_password_has_been_sent_to, user_name: @user.title ) )
      end

      it "should send an email containing alias and a password the user can login with" do
        email_text = ActionMailer::Base.deliveries.last.to_s
        email_text.should include @user.alias
        email_text.should include I18n.t(:password)
        email_text.should include root_path
        password_line = email_text.lines.find { |s| s.include? t(:password) }
        if password_line.include? "<td>"
          password = password_line.split("<td>").last.split("</td>").first
        else
          password = password_line.split(' ').last
        end
        password.should be_kind_of String
        password.should be_present

        logout

        visit sign_in_path
        within "#content_area" do
          fill_in 'user_account_login', with: @user.alias
          fill_in 'user_account_password', with: password

          click_on :login
        end
        page.should have_content I18n.t :logout
      end

      it "should change the user's password" do
        old_encrypted_password = @user.account.encrypted_password
        old_encrypted_password.should_not be_nil
        send_new_password
        User.first.account.encrypted_password.should_not == old_encrypted_password
      end

    end
  end
end
