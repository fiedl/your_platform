class CreateProfileFields < ActiveRecord::Migration[4.2]
  def change
    create_table :profile_fields do |t|
      t.integer     :user_id
      t.string      :label
      t.string      :type
      t.string      :value
      t.timestamps
    end
  end
end
