# This migration comes from your_platform (originally 20160802130323)
class AddInReplyToToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :in_reply_to, :string
  end
end
