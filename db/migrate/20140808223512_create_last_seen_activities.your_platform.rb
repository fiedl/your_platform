class CreateLastSeenActivities < ActiveRecord::Migration
  def change
    create_table :last_seen_activities do |t|
      t.integer :user_id
      t.string :description
      t.integer :link_to_object_id
      t.string :link_to_object_type

      t.timestamps
    end
  end
end
