require 'spec_helper'

feature "Profile fields maintenance view", :js do
  include SessionSteps

  before do
    @user = create :user
    @phone_field = @user.profile_fields.create label: "Phone", value: "1234", type: "ProfileFieldTypes::Phone"
  end

  scenario "listing the profile fields" do
    login :admin
    visit profile_fields_path(user_id: @user.id)

    page.should have_text @user.name
    page.should have_text @user.email
    page.should have_text @phone_field.label
    page.should have_text @phone_field.value
  end

  scenario "removing a profile field" do
    login :admin
    visit profile_fields_path(user_id: @user.id)

    within "table.profile_fields" do
      within ".profile-field-#{@phone_field.id}" do
        find('.remove_button').click
      end
    end

    page.should have_no_text "Phone"
    page.should have_no_text "1234"

    @user.profile_fields.pluck(:id).should_not include @phone_field.id
    ProfileField.where(id: @phone_field.id).should == []
  end

  scenario "adding a profile field" do
    login :admin
    visit profile_fields_path(user_id: @user.id)

    profile_fields_count_before = @user.profile_fields.count
    click_on I18n.t(:add_profile_field)

    within "table.profile_fields tbody" do
      page.should have_selector 'tr', count: profile_fields_count_before + 1
    end
    @user.profile_fields(true).count.should == profile_fields_count_before + 1
  end
end