require 'spec_helper'

feature "UserForgotPassword" do

  before do
    @user = User.create( first_name: "John", last_name: "Doe", email: "j.doe@example.com", :alias => "j.doe", 
                         create_account: true )
    @user.save
  end

  describe "Profile Page" do
    it "should contain the send-new-password link" do
      visit user_path( @user )
      page.should have_link I18n.t( :send_new_password ) 
    end
  end

  describe "Send New Password Action" do

    def send_new_password
      visit user_path( @user )
      click_link I18n.t( :send_new_password )
    end
    
    before do
      send_new_password
    end

    it "should send a flash message" do
      page.should have_content( I18n.t( :new_password_has_been_sent_to, user_name: @user.title ) )
    end

    it "should send an email containing alias and a password the user can login with" do
      email_text = ActionMailer::Base.deliveries.last.to_s
      email_text.include?( @user.alias ).should be_true
      email_text.include?( "Passwort" ).should be_true # TODO: change this later to use I18n
      password_line = email_text.lines.find { |s| s.starts_with? "Passwort:" } # TODO: change this later to use I18n
      password = password_line.split( ' ' ).last
      UserAccount.authenticate( @user.alias, password ).should_not == nil
    end

    it "should change the user's password" do
      old_password_digest = @user.account.password_digest
      old_password_digest.should_not be_nil
      send_new_password
      User.first.account.password_digest.should_not == old_password_digest
    end

  end

end
