# This migration comes from your_platform (originally 20170623184118)
class CreateDecisionMakingSignatures < ActiveRecord::Migration
  def change
    create_table :decision_making_signatures do |t|
      t.integer :user_id
      t.string :signable_type
      t.string :signable_id
      t.string :verified_by

      t.timestamps null: false
    end
  end
end
