class AddAvatarIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :avatar_id, :string
  end
end
