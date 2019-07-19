# This migration comes from your_platform (originally 20160802154036)
class AddIncomingMailIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :incoming_mail_id, :integer
  end
end
