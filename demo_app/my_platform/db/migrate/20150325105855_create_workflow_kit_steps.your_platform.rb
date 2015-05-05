# This migration comes from your_platform (originally 20120722005023)
# This migration comes from workflow_kit (originally 20120721140135)
class CreateWorkflowKitSteps < ActiveRecord::Migration
  def change
    create_table :workflow_kit_steps do |t|
      t.integer :sequence_index
      t.references :workflow
      t.string :brick_name

      t.timestamps
    end
  end
end
