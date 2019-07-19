# This migration comes from your_platform (originally 20160802133621)
class AddIncomingMailIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :incoming_mail_id, :integer
  end
end
