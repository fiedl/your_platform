require 'spec_helper'

feature "Role Preview" do
  include SessionSteps
  
  before do
    @group = create :group
    @user = create :user_with_account
    
    @group.admins << @user
  end
  
  scenario "Using role previews as local group admin" do
    login @user
    visit group_profile_path(@group)
    
    Role.of(@user).for(@group).to_s.should == 'admin'
    Role.of(@user).for(@group).admin?.should == true
    Role.of(@user).for(@group).officer?.should == true
    
    within "#logged-in-bar" do
      within ".role-preview-switcher" do
        page.should have_text I18n.t(:admin)
        within ".dropdown-menu" do
          page.should have_selector '.issues_task'
          page.should have_text "0 #{I18n.t(:administrative_issues)}"
          page.should have_text I18n.t(:admin)
          page.should have_text I18n.t(:officer)
          page.should have_text I18n.t(:user)
        end
      end
    end
    
    within ".role-preview-switcher" do
      click_on "0 #{I18n.t(:administrative_issues)}"
    end
    within ".box.first" do
      page.should have_text "#{I18n.t(:administrative_issues)} (0)"
    end
    
    visit group_profile_path(@group)
    within ".box.first" do
      page.should have_text I18n.t(:edit)
    end
    within ".role-preview-switcher" do
      click_on I18n.t(:officer)
    end
    within ".box.first" do
      page.should have_no_text I18n.t(:edit)
    end
    within ".role-preview-switcher" do
      click_on I18n.t(:admin)
    end
    within ".box.first" do
      page.should have_text I18n.t(:edit)
    end
    
  end
end