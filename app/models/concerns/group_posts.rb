concern :GroupPosts do

  included do
    has_many :posts
  end

  def posts
    Post.where(id: super).or(Post.where(id: child_posts))
  end

end