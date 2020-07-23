concern :UserPosts do

  included do
    has_many :posts, foreign_key: :author_user_id
  end

  def drafted_posts
    posts.draft
  end

  def posts_for_me
    Post.from_or_to_user(self)
  end
  def posts_in_my_groups
    Post.to_user_via_group(self)
  end

end