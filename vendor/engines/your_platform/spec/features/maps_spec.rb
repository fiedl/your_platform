require 'spec_helper'
include SessionSteps

feature "Maps", js: true do
  
  background do
    @user = create(:user_with_account)
    @user.profile_fields.create(type: "ProfileFieldTypes::Address", value: "Pariser Platz 1\n 10117 Berlin")
  end
  
  scenario "visiting a user page and looking at the map" do
    login(:user)
    visit user_path(@user)
    
    within(".section.contact_information") do
      page.should have_text "10117 Berlin"  
      page.should have_selector "div.gmnoprint"
    end
  end
  
  scenario "visiting a user page via turbolinks and looking at the map" do
    login(@user)
    visit root_path
    
    defined?(Turbolinks).should be_true
    find("a.my_profile").click
    
    within(".box.section.contact_information") do
      page.should have_text "10117 Berlin"  
      page.should have_selector "div.gmnoprint"
    end
  end
  
  scenario "visting a group page and looking at the members' map" do
    login(:user)
    visit group_path(Group.everyone)
    
    within(".large_map.section") do
      page.should have_selector "div.gmnoprint"
    end
  end
  
end
