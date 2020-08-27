concern :UserPosts do

  included do
    has_many :posts_from_me, class_name: "Post", foreign_key: :author_user_id
  end

  def drafted_posts
    posts_from_me.draft
  end

  # This method returns
  #
  # 1. Posts that are direclty shared with me by being a child_user of the post.
  # 2. Posts that are by me by the author_user_id attribute.
  # 3. Posts that are child_posts of my groups.
  # 4. Posts that are posts of my groups. (Legacy)
  # 5. Posts in events in my groups.
  #
  def posts
    Post.where(id: child_posts).or(
      Post.where(id: posts_from_me)
    ).or(
      Post.where(id: Post.joins(:parent_groups).where(groups: {id: self.groups}))
    ).or(
      Post.where(group_id: self.groups)
    ).or(
      Post.where(id: Post.joins(:parent_events).merge(Event.where(group_id: self.groups)))
    )
  end

end