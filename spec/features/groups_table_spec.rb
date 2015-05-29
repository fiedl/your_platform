require 'spec_helper'
include SessionSteps

feature "Groups Table" do
  background do
    @group = create(:group)
    @user = create(:user_with_account)
    @group.assign_user @user, at: 10.days.ago
  end
  scenario "viewing the groups table as regular user" do
    login :user
    visit user_path(@user)
    within all(".user_groups").last do
      page.should have_no_selector '.remove_button'
    end
  end
  scenario "viewing the groups table as administrator" do
    login :admin
    visit user_path(@user)
    within all(".user_groups").last do
      # We've removed that interface element, since it was confusing here:
      # People tried to end memberships through this.
      page.should have_no_selector '.remove_button' 
    end
  end
  scenario "viewing the own groups table" do
    login @user
    visit user_path(@user)
    within all(".user_groups").last do
      page.should have_no_selector '.remove_button'
    end
  end
  
end