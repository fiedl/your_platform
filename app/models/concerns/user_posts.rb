concern :UserPosts do
  
  included do
    has_many :posts, foreign_key: :author_user_id
  end
  
  def posts_for_me
    posts_in_my_groups
  end
  def posts_in_my_groups
    Post.where(group_id: self.group_ids)
  end
  
end