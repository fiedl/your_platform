# This configures the cache key length such that it can be persistent.
#
#
# ## Explanation
#
# A typical cache key of a User looks like this, where the last part
# comes from the User#updated_at timestamp.
#
#     users/4190-20151103154958215857000
# 
# Unfortunately, after reloading the user from the database, the cache key
# is changed, because the timestamp is stored with less precision in the 
# database as in memory.
# 
#     users/4190-20151103154958000000000
#
# With our current database setup, the updated_at column is only stored with
# a precision of integer seconds.
#
# Therefore, we shorten the cache key to:
#
#     users/4190-20151103154958
#
#
# ## Cache Timestamp Formats
#
# Possible formats are defined at: `Time::DATE_FORMATS`
# http://api.rubyonrails.org/classes/Time.html
#
#     :nsec   (nanoseconds)
#     :usec   (microseconds)
#     :number (seconds)          <-- currently stored in database
#
Rails.application.config.active_record.cache_timestamp_format = :number

class ActiveRecord::Base
  def self.cache_timestamp_format
    Rails.application.config.active_record.cache_timestamp_format
  end
end