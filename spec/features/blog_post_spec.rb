require 'spec_helper'

feature "Adding a BlogPost", :js do
  include SessionSteps
  
  background do
    @page = Page.create(title: "My Shiny Page")
  end
  scenario "Adding a blog post" do
    login(:admin)
    visit page_path(@page)

    click_on I18n.t(:add_blog_post)
    wait_for_ajax; wait_for_ajax
    
    # After clicking the link to add a blog post, there should be a new blog post
    # that is already in edit_mode.
    page.should have_selector ".best_in_place.editable input[type='text']"
  end
  
  scenario "(bug fix) one should not be able to create blog posts as child of a blog post" do
    #
    # @apge
    #   |----- @blog_post
    #   |----- @another_blog_post
    #                 |----------- @this_blog_post_is_not_ok
    #
    # When officers look at @another_blog_post and click 'add blog post', they might
    # expect the post to appear as child of @page, but not as child of @another_blog_post.
    # Therefore, we remove the 'add blog post' button in the blog post detail view.
    #
    @another_blog_post = BlogPost.create title: 'Another blog post'
    @page.child_pages << @another_blog_post
    
    login :admin
    
    visit page_path(@page)
    page.should have_text I18n.t :add_blog_post
    
    visit blog_post_path(@another_blog_post)
    page.should have_no_text I18n.t :add_blog_post

    visit page_path(@another_blog_post)
    page.should have_no_text I18n.t :add_blog_post
  end
end
