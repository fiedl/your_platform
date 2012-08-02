# -*- coding: utf-8 -*-
require 'spec_helper'

describe "User page" do
    let(:user) { FactoryGirl.create(:user) }

  subject { page }
  
  context "when not signed in" do
    before do
      visit user_path(user)
    end
    
    #it { should have_content "Access denied" }
  end

  context "when signed in" do  
    before do 
      user.save
      password = user.account.password
      #puts password
      page.save_page
      visit user_path(user)
    end
  
    it { should have_selector('h1', text: "About Myself") }
    it { should have_selector('h1', text: "Study Information") }
    it { should have_selector('h1', text: "Career Information") }
    it { should have_selector('h1', text: "Organizations") }
    it { should have_selector('title', text: "Wingolfsplattform") }
  end 
end

