# This migration comes from workflow_kit (originally 20120721140135)
class CreateWorkflowKitSteps < ActiveRecord::Migration[4.2]
  def change
    create_table :workflow_kit_steps do |t|
      t.integer :sequence_index
      t.references :workflow
      t.string :brick_name

      t.timestamps
    end
  end
end
