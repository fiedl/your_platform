# This migration comes from your_platform (originally 20130404223735)
class AddEntireMessageToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :entire_message, :text
  end
end
