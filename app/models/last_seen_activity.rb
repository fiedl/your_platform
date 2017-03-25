class LastSeenActivity < ActiveRecord::Base

  belongs_to :user
  belongs_to :link_to_object, polymorphic: true

  def self.current
    where('updated_at > ?', 5.minutes.ago).order('created_at')
  end
end
