class CreateDecisionMakingVotes < ActiveRecord::Migration
  def change
    create_table :decision_making_votes do |t|
      t.integer :process_id
      t.integer :option_id
      t.integer :user_id
      t.integer :group_id

      t.timestamps null: false
    end
  end
end
