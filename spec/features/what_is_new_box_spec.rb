require 'spec_helper'

feature "What's-new Box on root#index" do
  # include SessionSteps
  # 
  # background do
  #   @user = create :user_with_account
  #   @group = create :group
  #   @group.assign_user @user, at: 1.year.ago
  #   @other_group = create :group
  #   
  #   @page_of_group = @group.child_pages.create title: 'Page of a group the user is member of'
  #   @page_of_other_group = @other_group.child_pages.create title: 'Page of a group the user is NOT member of'
  #   @page_without_group = create :page, title: 'Page without a group, i.e. a global page'
  # end
  # 
  # scenario 'Looking at the what-is-new box on root#index' do
  #   login @user
  #   visit root_path
  #   
  #   within '.box.what_is_new' do
  #     
  #     # List the pages of the groups the user is member of
  #     page.should have_text @page_of_group.title
  #     
  #     # Do not list the pages of groups the user is not member of
  #     page.should have_no_text @page_of_other_group.title
  #     
  #     # List the pages without group, i.e. "global pages"
  #     page.should have_text @page_without_group.title
  #   end
  end
end