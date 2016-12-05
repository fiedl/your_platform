class Blog < Page

  def blog_posts
    child_pages.where(type: 'BlogPost')
  end

end