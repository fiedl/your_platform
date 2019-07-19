class AddMessageIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :message_id, :string
  end
end
