class State < ApplicationRecord

  belongs_to :author, class_name: "User", foreign_key: "author_user_id", optional: true
  belongs_to :reference, polymorphic: true

  def to_s
    self.name
  end

  # Generic state checker method.
  #
  #     some_object.state.accepted?
  #
  def method_missing(method_name)
    if method_name.to_s.end_with? "?"
      name == method_name.to_s[0..-2]
    else
      super
    end
  end

end
