class AddSentViaToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :sent_via, :string
  end
end
