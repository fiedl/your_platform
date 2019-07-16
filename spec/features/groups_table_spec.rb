require 'spec_helper'
include SessionSteps

feature "Groups Table" do
  background do
    @group = create(:group)
    @user = create(:user_with_account)
    @group.assign_user @user, at: 10.days.ago
  end
  scenario "viewing the groups table as regular user", :js do
    login :user
    visit user_path(@user)
    click_on :more_info_tab

    # Nokogiri::CSS::SyntaxError:
    #        unexpected '$' after ''
    # means that `all(".user_groups").last` is nil.

    page.should have_selector ".user_groups"
    within all(".user_groups").last do
      page.should have_no_selector '.remove_button'
    end
  end
  scenario "viewing the groups table as administrator" do
    login :admin
    visit user_path(@user)
    click_on :more_info_tab

    within all(".user_groups").last do
      # We've removed that interface element, since it was confusing here:
      # People tried to end memberships through this.
      page.should have_no_selector '.remove_button'
    end
  end
  scenario "viewing the own groups table" do
    login @user
    visit user_path(@user)
    click_on :more_info_tab

    within all(".user_groups").last do
      page.should have_no_selector '.remove_button'
    end
  end

end