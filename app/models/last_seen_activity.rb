class LastSeenActivity < ApplicationRecord

  belongs_to :user
  belongs_to :link_to_object, polymorphic: true, optional: true

  def self.current
    where('updated_at > ?', 5.minutes.ago).order('created_at')
  end
end
