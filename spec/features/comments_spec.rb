require 'spec_helper'

feature "Comments" do
  include SessionSteps
  
  background do
    @posting_user = create :user_with_account
    @commenting_user = create :user_with_account

    @group = create :group
    @group << @posting_user
    @group << @commenting_user
    
    @post = @group.posts.create author_user_id: @posting_user.id, subject: "Test Post", text: "Text of the post.", sent_at: 1.hour.ago
  end
  
  scenario "Commenting on a post on the posts view", :js do
    login @commenting_user
    visit post_path(@post)
    
    page.should have_no_selector '.submit_comment', visible: true
    
    fill_in :comment_text, with: "Text of the comment."
    page.should have_selector '.submit_comment', visible: true

    click_on I18n.t(:submit_comment)
    page.should have_no_selector '.submit_comment', visible: true
    within('textarea#comment_text') { page.should have_no_text "Text of the comment." }
    page.should have_text "Text of the comment."
    
    @posting_user.notifications.last.reference.should_not == nil
    @posting_user.notifications.last.reference.should == Comment.last
  end
  
end