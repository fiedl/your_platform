class Pages::PublicPage < Page

  def root
    ancestor_pages.where(type: "Pages::PublicPage").first || self
  end

  def menu_items
    [root] + root.public_child_pages
  end

  def public_child_pages
    child_pages.public_pages
  end

  def active_menu_page
    return self if root == self
    return self if parent == root
    return (root.child_pages & self.ancestor_pages).first
  end

  def posts
    child_posts
  end

  def posts
    Post.where(id: child_posts).or(Post.where(id: group_posts))
  end

  def group_posts
    if self == root
      Post.joins(:parent_groups).merge(group.posts).public_post
    else
      Post.none
    end
  end


end