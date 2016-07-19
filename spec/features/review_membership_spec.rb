require 'spec_helper'

feature "review membership" do
  include SessionSteps

  background do
    @user = create(:user)

    @profile_field = @user.profile_fields.create(type: 'ProfileFieldTypes::Phone', label: 'My Phone', value: '0123 456 789')
    @profile_field.needs_review!

    @corporation = create(:corporation_with_status_groups)
    @group = @corporation.status_groups.first
    @membership = @group.assign_user @user
    @membership.needs_review!

    login(:admin)
  end

  scenario "viewing user's profile an accepting a membership that is to be reviewed", :js, :timeout => 30.seconds do

    visit user_path(@user)

    click_tab :corporate_info_tab
    within ".box.section.corporate_vita" do
      page.should have_text @group.name
      page.should have_selector ".confirm-review-button"

      # click on the green button to accept the information.
      find(".confirm-review-button").click
      wait_for_ajax

      # the button should disappear and the membership should still be visible.
      page.should have_no_selector ".confirm-review-button", visible: true
      page.should have_text @group.name

      # in the database, the membership should not be marked as to be reviewed, now.
      @membership.reload.needs_review?.should == false

    end
  end

  pending "viewing user's profile and accepting a profile field that is to be reviewed"

end