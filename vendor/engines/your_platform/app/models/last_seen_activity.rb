class LastSeenActivity < ActiveRecord::Base
  attr_accessible :description, :link_to_object_id, :link_to_object_type, :user_id
  
  belongs_to :user
  belongs_to :link_to_object, polymorphic: true
  
  def self.current
    where('updated_at > ?', 5.minutes.ago).order(:created_at)
  end
end
