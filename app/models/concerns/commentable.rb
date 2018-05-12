concern :Commentable do

  included do
    has_many :comments, as: :commentable, dependent: :destroy
  end

  def comments_enabled?
    comments_enabled || false
  end

  def comments_enabled
    self.settings.comments_enabled
  end

  def comments_enabled=(new_setting)
    self.settings.comments_enabled = new_setting
  end

end