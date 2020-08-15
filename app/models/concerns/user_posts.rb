concern :UserPosts do

  included do
    has_many :posts, foreign_key: :author_user_id
  end

  def drafted_posts
    posts.draft
  end

  def posts_for_me
    Post.where(id: groups.collect { |group| group.descendant_post_ids + group.post_ids } + descendant_post_ids + post_ids)
  end

end