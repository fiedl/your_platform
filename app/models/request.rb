# As we have deactivated the who-is-online feature,
# we'll need a way to determine if we can safely
# restart services.
#
# This model keeps track of user requests.
# But we delete the user id later.
#
# Using the ip, which is stored, we try to identify
# if several requests belong to a single visit.
#
class Request < ApplicationRecord
  belongs_to :navable, polymorphic: true, optional: true
  after_commit { Request.delay.purge_user_id_from_the_database }

  def self.create(attrs)
    obj = super(attrs.except(:user_id))
    obj.cached_user_id = attrs[:user_id]
    return obj
  end

  def user_id
    Rails.cache.read [self.cache_key, "user_id"]
  end

  def cached_user_id=(new_id)
    Rails.cache.write [self.cache_key, "user_id"], new_id,
        expires_in: 1.week
  end

  def user
    User.find(user_id) if user_id
  end

  def cache_key
    "requests/#{self.id}" # without timestamp
  end

  # We only want to have access to the user id for a limited time
  # for privacy reqsons. In this time, we use this for debugging
  # and support.
  #
  # In order not to have any permanent record, we transfer the
  # user id to the cache, where it lives for a limited time.
  # The user id is purged from the database.
  #
  def self.purge_user_id_from_the_database
    Request.update_all(user_id: nil)
  end

end
