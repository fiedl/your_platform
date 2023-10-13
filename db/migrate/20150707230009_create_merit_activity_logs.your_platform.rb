# This migration comes from your_platform (originally 20150707222858)
class CreateMeritActivityLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :merit_activity_logs do |t|
      t.integer  :action_id
      t.string   :related_change_type
      t.integer  :related_change_id
      t.string   :description
      t.datetime :created_at
    end
  end
end
