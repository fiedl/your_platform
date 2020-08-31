concern :GroupPosts do

  included do
    has_many :legacy_posts, class_name: 'Post'
  end

  # This combines:
  #
  #     group.legacy_posts
  #     group.child_posts   # new default
  #
  def posts
    Post.where(id: legacy_posts).or(Post.where(id: child_posts))
  end

  def create_post(attrs = {})
    child_posts.create attrs
  end

end