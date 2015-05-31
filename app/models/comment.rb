class Comment < ActiveRecord::Base
  attr_accessible :text
  
  belongs_to :author, foreign_key: :author_user_id, class_name: 'User'
  belongs_to :commentable, polymorphic: true
  
end
