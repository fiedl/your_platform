concern :HasAuthor do

  included do
    belongs_to :author, :class_name => "User", foreign_key: 'author_user_id'
  end

  def author_title=(new_title)
    self.author = User.find_by_title(new_title)
  end
  def author_title
    self.author.try(:title)
  end

end