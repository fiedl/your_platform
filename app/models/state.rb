class State < ApplicationRecord

  belongs_to :author, class_name: "User", foreign_key: "author_user_id", optional: true
  belongs_to :reference, polymorphic: true

  def to_s
    self.name
  end

end
