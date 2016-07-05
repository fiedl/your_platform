class Comment < ActiveRecord::Base
  attr_accessible :text if defined? attr_accessible

  belongs_to :author, foreign_key: :author_user_id, class_name: 'User'
  belongs_to :commentable, polymorphic: true

  has_many :mentions, as: :reference
  has_many :mentioned_users, through: :mentions, class_name: 'User', source: 'whom'

end
