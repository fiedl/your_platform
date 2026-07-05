# This migration comes from your_platform (originally 20150313221004)
class AddAvatarIdToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :avatar_id, :string
  end
end
