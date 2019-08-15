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
    Page.find_root.update_attributes content: "This is our public website!", published_at: 1.year.ago, domain: "example.com"

    visit root_path
    within("#content_area") { page.should have_text "This is our public website!" }
  end

  scenario "Looking at the news pages at the intranet root" do
    @user = create :user_with_account
    @group = create :group
    @group.assign_user @user, at: 1.year.ago
    @other_group = create :group

    @blog_of_group = @group.child_pages.create title: "Blog of a group the user is member of", published_at: 1.day.ago
    @blog_post_of_group = @blog_of_group.child_pages.create title: 'Blog post of a group the user is member of', content: "This page needs content to be shown.", published_at: 1.day.ago, type: "BlogPost"
    @blog_of_other_group = @other_group.child_pages.create title: "Blog post of a group the user is NOT member of", published_at: 1.day.ago
    @blog_post_of_other_group = @blog_of_other_group.child_pages.create title: 'Blog post of a group the user is NOT member of', content: "This page needs content to be shown.", published_at: 1.day.ago, type: "BlogPost"
    @blog_without_group = create :page, title: "Blog without a group, i.e. a global blog", published_at: 1.day.ago
    @blog_post_without_group = @blog_without_group.child_pages.create title: 'Blog post without a group, i.e. a global page', content: "This page needs content to be shown.", published_at: 1.day.ago, type: "BlogPost"
    @unpublished_blog_post = @blog_without_group.child_pages.create title: "Unpublished blog post in published blog", published_at: nil, type: "BlogPost"

    @document_of_published_blog_post = create :attachment, title: "Document of published blog post"; @blog_post_of_group.attachments << @document_of_published_blog_post
    @document_of_unpublished_blog_post = create :attachment, title: "Document of unpublished blog post"; @unpublished_blog_post.attachments << @document_of_unpublished_blog_post

    login @user
    visit root_path

    within '#content_area' do
      # List the pages of the groups the user is member of
      page.should have_text @blog_post_of_group.title

      # Do not list the pages of groups the user is not member of
      page.should have_no_text @blog_post_of_other_group.title

      # List the pages without group, i.e. "global pages"
      page.should have_text @blog_post_without_group.title

      # Do not list unpublished blog posts
      page.should have_no_text @unpublished_blog_post.title

      # List documents of visible blog posts
      page.should have_text @document_of_published_blog_post.title

      # Do not list documents of unpublished blog posts
      page.should have_no_text @document_of_unpublished_blog_post
    end
  end
end