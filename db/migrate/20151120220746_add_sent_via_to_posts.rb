class AddSentViaToPosts < ActiveRecord::Migration[4.2]
  def change
    add_column :posts, :sent_via, :string
  end
end
