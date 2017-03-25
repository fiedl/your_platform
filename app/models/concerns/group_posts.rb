concern :GroupPosts do

  included do
    has_many :posts
  end

  def descendant_post_ids
    descendant_groups.map(&:post_ids).flatten
  end
  def descendant_posts
    Post.where(id: descendant_post_ids)
  end

end