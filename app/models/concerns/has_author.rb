concern :HasAuthor do

  included do
    belongs_to :author, class_name: 'User', foreign_key: 'author_user_id', optional: true

    scope :by_author, -> (user) { user ? where(author_user_id: user.id) : none }
  end

  def author_title=(new_title)
    self.author = User.find_by_title(new_title)
  end
  def author_title
    self.author.try(:title)
  end

  def contributors
    [author] - [nil]
  end

end