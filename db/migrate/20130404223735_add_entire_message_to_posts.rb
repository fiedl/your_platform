class AddEntireMessageToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :entire_message, :text
  end
end
