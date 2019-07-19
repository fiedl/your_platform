# This migration comes from your_platform (originally 20160802150935)
class AddMessageIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :message_id, :string
  end
end
