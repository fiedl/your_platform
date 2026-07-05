# This migration comes from your_platform (originally 20180623154145)
class AddCommentToStates < ActiveRecord::Migration[5.0]
  def change
    add_column :states, :comment, :text
  end
end
