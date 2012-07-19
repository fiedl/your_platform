# -*- coding: utf-8 -*-
require 'spec_helper'

describe "User page" do
    let(:user) { FactoryGirl.create(:user) }

  subject { page }
  
  context "when not signed in" do
    before do
      visit user_path(user)
    end
    
    it { should have_content "Access denied" }
  end

  context "when signed in" do  
    before do 
      user.save
      password = user.account.password
      puts password
      visit user_path(user)
    end
  
    #it { should have_selector('h1', text: "Vereine und Organisationen") }
    #it { should have_selector('title', text: user.name) }
  end 
end

