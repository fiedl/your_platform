# We store all outgoing email deliveries for delivery reports
# and, if needed, for later debugging.
#
#   integer  "deliverable_id",
#   string   "deliverable_type
#   integer  "user_id",
#   string   "user_email",
#   datetime "sent_at"
#   datetime "failed_at"
#   string   "comment",
#   datetime "created_at",
#   datetime "updated_at",
#   string   "message_id",
#   string   "subject",
#   string   "in_reply_to",
#
class Delivery < ActiveRecord::Base

  belongs_to :deliverable, polymorphic: true
  belongs_to :user

  scope :sent, -> { where.not(sent_at: nil) }
  scope :failed, -> { where.not(failed_at: nil) }
  scope :due, -> { where(sent_at: nil, failed_at: nil) }

end