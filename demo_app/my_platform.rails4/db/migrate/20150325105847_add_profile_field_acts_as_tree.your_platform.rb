# This migration comes from your_platform (originally 20120508130729)
class AddProfileFieldActsAsTree < ActiveRecord::Migration

  def change
    change_table :profile_fields do |t|
      t.integer :parent_id
    end
  end

end
