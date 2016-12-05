concern :Commentable do

  included do
    has_many :comments, as: :commentable, dependent: :destroy
  end

end