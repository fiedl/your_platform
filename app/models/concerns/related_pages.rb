concern :RelatedPages do

  def related_blog_posts
    related_objects.where(type: "BlogPost")
  end

  def related_pages
    related_objects
  end

  def related_objects
    self.find_related_tags
  end

end