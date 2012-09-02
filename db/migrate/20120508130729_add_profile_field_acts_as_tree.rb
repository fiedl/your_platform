class AddProfileFieldActsAsTree < ActiveRecord::Migration

  def change
    change_table :profile_fields do |t|
      t.integer :parent_id
    end
  end

end
