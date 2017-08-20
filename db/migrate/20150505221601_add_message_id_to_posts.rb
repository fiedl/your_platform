class AddMessageIdToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :message_id, :string
    add_column :posts, :content_type, :string
  end
end
