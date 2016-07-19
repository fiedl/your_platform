require 'spec_helper'

feature "Postal Address Flag" do
  include SessionSteps

  background do
    @user = create(:user_with_account)
    @home_address = @user.profile_fields.create( label: "Home Address", value: "Pariser Platz 1\n 10117 Berlin",
                                                 type: "ProfileFieldTypes::Address" )
      .becomes(ProfileFieldTypes::Address)
    @study_address = @user.profile_fields.create( label: "Study Address", value: "Pariser Platz 1\n 10117 Berlin",
                                                  type: "ProfileFieldTypes::Address" )
      .becomes(ProfileFieldTypes::Address)
  end
  scenario "Selecting a postal address in the own user profile.", js: true do

    login :admin
    visit user_path @user

    click_tab :contact_info_tab
    within ".box.section.contact_information" do

      page.should have_no_selector('.postal_address .label.radio', visible: true)
      @user.postal_address_field.should == nil

      click_on I18n.t(:edit)
      first("input[type='radio']").click()
      wait_for_ajax
    end

    visit user_path @user
    click_tab :contact_info_tab
    within ".box.section.contact_information" do
      page.should have_content "Home Address #{@user.name} #{@home_address.value} Postanschrift".gsub("\n", "")
      page.should have_no_content "Study Address #{@user.name} #{@study_address.value} Postanschrift".gsub("\n", "")
      @user.reload.postal_address_field.should == @home_address

      click_on I18n.t(:edit)
      find(".postal_address.profile_field_#{@study_address.id} input[type='radio']").click()
      wait_for_ajax
    end

    visit user_path @user
    click_tab :contact_info_tab
    within ".box.section.contact_information" do
      page.should have_no_content "Home Address #{@user.name} #{@home_address.value} Postanschrift".gsub("\n", "")
      page.should have_content "Study Address #{@user.name} #{@study_address.value} Postanschrift".gsub("\n", "")
      @user.reload.postal_address_field.should == @study_address
    end

  end
end