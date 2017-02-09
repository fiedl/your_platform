class Blog < Page

  def blog_posts
    descendant_blog_posts
  end

end