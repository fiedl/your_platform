class AddMessageIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :message_id, :string
    add_column :posts, :content_type, :string
  end
end
