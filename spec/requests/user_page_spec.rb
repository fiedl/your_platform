# -*- coding: utf-8 -*-
require 'spec_helper'

describe "User page", js: false do
  before do
    User.destroy_all
    @user = create( :user_with_account )
    @login_string = @user.alias
    @password = @user.account.password
  end

  subject { page }
  
  context "when not signed in" do
    before do
      visit user_path( @user )
    end
    
    #it { should have_content "Access denied" }
  end

  context "when signed in" do  
    before do 

      visit new_session_path
      fill_in 'login_name', with: @login_string
      fill_in 'password', with: @password
      click_button :login # I18n.t( :login )

      visit user_path( @user )
    end
  
    it { should have_selector('h1', text: "About Myself") }
    it { should have_selector('h1', text: "Study Information") }
    it { should have_selector('h1', text: "Career Information") }
    it { should have_selector('h1', text: "Organizations") }
    it { should have_selector('title', text: "Wingolfsplattform") }
  end 
end

