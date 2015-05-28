require 'spec_helper'

feature "Intranet Root" do
  include SessionSteps

  scenario "Viewing the intranet root page when not logged in and the public website is not done with this system" do
    create :user_with_account
    Page.find_root.update_attribute :redirect_to, "http://example.com"
      
    # The user is *not* logged in. Just visit the start page.
    visit root_path
      
    # This should redirect to the login page.
    within("#content_area") { page.should have_content I18n.t(:login) }
  end
  
  scenario "Viewing the intranet root page when not logged in and the public website is done with this system" do
    create :user_with_account
    Page.find_root.update_attribute :content, "This is our public website!"
    Page.public_website_page_ids(true)
    
    visit root_path
    within("#content_area") { page.should have_text "This is our public website!" }
  end
  
  scenario "Looking at the news pages at the intranet root" do
    @user = create :user_with_account
    @group = create :group
    @group.assign_user @user, at: 1.year.ago
    @other_group = create :group
    
    @page_of_group = @group.child_pages.create title: 'Page of a group the user is member of', content: "This page needs content to be shown."
    @page_of_other_group = @other_group.child_pages.create title: 'Page of a group the user is NOT member of', content: "This page needs content to be shown."
    @page_without_group = create :page, title: 'Page without a group, i.e. a global page', content: "This page needs content to be shown."
    
    login @user
    visit root_path
    
    within '#content_area' do
      # List the pages of the groups the user is member of
      page.should have_text @page_of_group.title
      
      # Do not list the pages of groups the user is not member of
      page.should have_no_text @page_of_other_group.title
      
      # List the pages without group, i.e. "global pages"
      page.should have_text @page_without_group.title
    end
  end
end