# This migration comes from your_platform (originally 20151120220746)
class AddSentViaToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :sent_via, :string
  end
end
