require 'spec_helper'

feature "Profile", :js do
  include SessionSteps

  context "logged in as group admin" do
    before do
      @user = create :user_with_account
      @group = create :group
      @group.assign_admin @user

      login @user
    end

    scenario "editing the group profile" do
      @profile_field = @group.profile_fields.create(label: 'Group Phone', type: 'ProfileFields::Phone', value: "123-4")

      visit group_profile_path(@group)
      within('.box.contact_information') do
        click_on I18n.t(:edit)
        fill_in "value", with: "456-789-0"
        click_on I18n.t(:save)
      end

      page.should have_text "456-789-0"

      visit group_profile_path(@group)
      page.should have_text "456-789-0"
    end

    scenario "adding a group profile field" do
      visit group_profile_path(@group)
      within('.box.contact_information') do
        click_on I18n.t(:edit)
        click_on I18n.t(:add)
        click_on I18n.t(:phone)
        fill_in "value", with: "456-789-0"
        click_on :save

        page.should have_no_selector 'input', visible: true
      end

      page.should have_text "456-789-0"

      visit group_profile_path(@group)
      page.should have_text "456-789-0"
    end

  end

end