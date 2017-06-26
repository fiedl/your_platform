# This migration comes from your_platform (originally 20170623151707)
class CreateDecisionMakingProcesses < ActiveRecord::Migration
  def change
    create_table :decision_making_processes do |t|
      t.string :title
      t.string :type
      t.text :wording
      t.text :rationale
      t.integer :proposer_group_id
      t.integer :scope_group_id
      t.integer :creator_user_id
      t.string :required_majority
      t.datetime :proposed_at
      t.datetime :opened_for_voting_at
      t.datetime :deadline
      t.datetime :decided_at

      t.timestamps null: false
    end
  end
end
