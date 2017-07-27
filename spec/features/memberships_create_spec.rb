require 'spec_helper'

feature "memberships#create" do
  include SessionSteps

  scenario "Adding a member manually to a group", :js do
    @parent_group = create :group
    @group = @parent_group.child_groups.create
    @user = create :user

    login :admin
    visit group_members_path(group_id: @group.id)

    within '#new_membership' do
      fill_in :membership_user_title, with: @user.title
      sleep 0.3
      click_on I18n.t(:add)
    end

    wait_until(timeout: 60.seconds) { print "/"; page.has_no_text? "Mitglieder (0)" }

    within '#members' do
      page.should have_text @user.last_name
      page.should have_text @user.first_name
    end

    @user.should be_member_of @group
    @user.should be_member_of @parent_group
    Membership.with_past.find_by_user_and_group(@user, @group).valid_from.to_date.should == Time.zone.now.to_date
  end

end
