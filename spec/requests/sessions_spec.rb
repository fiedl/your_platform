require 'spec_helper'

describe "Sessions" do
  describe "New Session Page" do  # to show the browser while testing, e.g. use `js: true`.
    
    before do
      visit new_session_path
    end

    subject { page }

    describe "Form elements" do
      it { should have_field( 'login_name' ) }
      it { should have_field( 'password' ) }
    end

    it "should allow to create a new session" do
      
      @user = User.create( first_name: "John", last_name: "Doe", email: "j.doe@example.com", :alias => "j.doe" )
      @user.create_account = true
      @user.save
      @password = @user.account.password

      fill_in 'login_name', with: "John Doe"
      fill_in 'password', with: @password
      click_button I18n.t( "login" )
      
      page.should have_content( "John Doe" )
      page.should have_content( I18n.t( :logout ) )

    end


  end
end
