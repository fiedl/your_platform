class AddEntireMessageToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :entire_message, :text
  end
end
