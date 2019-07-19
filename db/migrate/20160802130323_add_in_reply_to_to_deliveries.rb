class AddInReplyToToDeliveries < ActiveRecord::Migration
  def change
    add_column :deliveries, :in_reply_to, :string
  end
end
