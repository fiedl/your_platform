require 'spec_helper'

feature "Pages" do
  include SessionSteps

  scenario "Visiting a page" do
    @page = Page.create(title: "My Shiny Page")
    login :user

    visit page_path(@page)
    page.should have_content "My Shiny Page"
  end

  scenario "creating a documents page as group officer" do
    @user = create :user_with_account
    @group = create :group
    @group.child_pages.create title: "Lorem ipsum"
    @office = @group.create_officer_group name: "President"
    @office.assign_user @user
    login @user

    visit group_members_path(@group)
    within '#vertical_nav' do
      find('.add_to_vertical_nav').click
      click_on :page
    end

    page.should have_text I18n.t(:new_page)
  end
end
