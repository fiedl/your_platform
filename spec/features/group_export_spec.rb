require 'spec_helper'

feature 'Group Member List Export' do
  include SessionSteps

  let(:group) { create :group }
  let(:user) { create :user }

  before do
    user.phone = "1234"
    user.localized_date_of_birth = "13.11.1986"
    user.home_address = "Berlin, Germany"
    user.save

    group.assign_user user

    login :admin
  end

  scenario "exporting a name_list as csv" do
    visit group_list_export_path group_id: group.id, list: 'name_list', format: 'csv'
    page.should have_text user.last_name
  end

  scenario "exporting an address_list as csv" do
    visit group_list_export_path group_id: group.id, list: 'address_list', format: 'csv'
    page.should have_text user.last_name
  end

  scenario "exporting a member_development list as csv" do
    visit group_list_export_path group_id: group.id, list: 'member_development', format: 'csv'
    page.should have_text user.last_name
  end

  scenario "exporting a join_statistics list as csv" do
    visit group_list_export_path group_id: group.id, list: 'join_statistics', format: 'csv'
    page.should have_text "#{group.name};1;0;"
  end

  scenario "exporting a dpag_internetmarken list as csv" do
    visit group_list_export_path group_id: group.id, list: 'dpag_internetmarken', format: 'csv'
    page.should have_text user.last_name

    visit group_list_export_path group_id: group.id, list: 'dpag_internetmarken_in_germany', format: 'csv'
    page.should have_text user.last_name
  end

  scenario "exporting a birthday_list as csv" do
    visit group_list_export_path group_id: group.id, list: 'birthday_list', format: 'csv'
    page.should have_text user.last_name
  end

  scenario "exporting a email_list as csv" do
    visit group_list_export_path group_id: group.id, list: 'email_list', format: 'csv'
    page.should have_text user.last_name
  end

  scenario "exporting a phone_list as csv" do
    visit group_list_export_path group_id: group.id, list: 'phone_list', format: 'csv'
    page.should have_text user.last_name
  end

  describe "with users with birthdays" do
    before do
      @user_with_birthday_in_q3 = create :user
      @user_with_birthday_in_q3.date_of_birth = "1986-08-24".to_date
      @user_with_birthday_in_q3.save
      group << @user_with_birthday_in_q3
      @user_with_birthday_in_q4 = create :user
      @user_with_birthday_in_q4.date_of_birth = "1986-11-13".to_date
      @user_with_birthday_in_q4.save
      group << @user_with_birthday_in_q4
    end

    scenario "exporting a birthday list of quarter 4" do
      visit group_list_export_path group_id: group.id, list: 'birthday_list', format: 'csv', quarter: 4
      page.should have_text @user_with_birthday_in_q4.last_name
      page.should have_text @user_with_birthday_in_q4.localized_date_of_birth
      page.should have_no_text @user_with_birthday_in_q3.last_name
      page.should have_no_text @user_with_birthday_in_q3.localized_date_of_birth
    end
  end
end