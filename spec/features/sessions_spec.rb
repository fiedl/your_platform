require 'spec_helper'

feature "Sessions" do
  describe "New Session Page" do  # to show the browser while testing, e.g. use `js: true`.
    
    before do
      visit sign_in_path
    end

    subject { page }

    describe "Form elements" do
      it { should have_field( 'user_account_login' ) }
      it { should have_field( 'user_account_password' ) }
    end

    it "should allow to create a new session" do
      
      @user = User.create( first_name: "John", last_name: "Doe", email: "j.doe@example.com", :alias => "j.doe" )
      @user.create_account = true
      @user.save
      @password = @user.account.password

      fill_in 'user_account_login', with: "John Doe"
      fill_in 'user_account_password', with: @password
      
      Timeout::timeout(30) do
        click_button I18n.t( :login )
      end
      page.should have_content( "John Doe" )
      page.should have_content( I18n.t( :logout ) )

    end


  end
end
