class AddProfileFieldActsAsTree < ActiveRecord::Migration[4.2]

  def change
    change_table :profile_fields do |t|
      t.integer :parent_id
    end
  end

end
