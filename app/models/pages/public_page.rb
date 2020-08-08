class Pages::PublicPage < Page

  def root
    ancestor_pages.where(type: "Pages::PublicPage").first || self
  end

  def menu_items
    [root] + root.public_child_pages
  end

  def public_child_pages
    child_pages.where(type: "Pages::PublicPage")
  end

end