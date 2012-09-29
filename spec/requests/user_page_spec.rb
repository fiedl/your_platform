# -*- coding: utf-8 -*-
require 'spec_helper'

describe "User page" do
  let(:user) { FactoryGirl.create(:user_with_account) }

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

    it { should have_link "OrganizationsEditButton"}
    it { should have_link "Save" } #how to test that it is hidden
    it { should have_link "Add" } #how to test that it is hidden

    describe "and clicking on the organizations edit button" do
      before { click_link "OrganizationsEditButton" }

    end
  end
end

