class Blog < Page

  include BlogSubscriptions

  def blog_posts
    descendant_blog_posts
  end

  def create_blog_post(attributes = {})
    new_blog_post = BlogPost.create(attributes)
    self << new_blog_post
    return new_blog_post.reload
  end

end