# This migration comes from your_platform (originally 20130404223735)
class AddEntireMessageToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :entire_message, :text
  end
end
