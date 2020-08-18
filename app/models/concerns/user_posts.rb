concern :UserPosts do

  included do
    has_many :posts_from_me, class_name: "Post", foreign_key: :author_user_id
  end

  def drafted_posts
    posts_from_me.draft
  end

  def posts
    Post.where(id: groups.collect { |group| group.child_post_ids + group.post_ids }.flatten + child_post_ids + post_ids)
  end

end