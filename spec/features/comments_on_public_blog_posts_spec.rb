require 'spec_helper'

feature "Comments on public blog posts", js: true do
  background do
    Page.root.update_attribute :type, "Blog"
    @blog = Page.root
    @blog_post = @blog.blog_posts.create(title: "Great blog post").becomes(BlogPost)
  end

  scenario "A guest user posts a comment on a public blog post" do
    visit blog_post_path(@blog_post)

    wait_until { page.has_selector? '.blog_post_comments' }
    within '.blog_post_comments' do
      fill_in :guest_user_name, with: "John Doe"
      fill_in :guest_user_email, with: "j.doe@example.com"
      fill_in :comment_text, with: "This is a great post, thanks!"
      click_on :submit_comment
    end

    within 'form.new_comment' do
      page.should have_no_text "This is a great post"
    end

    wait_until { @blog_post.comments(true).count > 0 }
    @blog_post = BlogPost.find @blog_post.id
    @blog_post.comments.count.should == 1
    @blog_post.comments.first.author.name.should == "John Doe"
  end
end
