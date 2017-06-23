class CreateDecisionMakingProcesses < ActiveRecord::Migration
  def change
    create_table :decision_making_processes do |t|
      t.string :title
      t.string :type
      t.text :wording
      t.text :rationale
      t.datetime :deadline
      t.datetime :decided_at
      t.datetime :proposed_at
      t.integer :proposer_group_id
      t.integer :scope_group_id
      t.integer :creator_user_id

      t.timestamps null: false
    end
  end
end
