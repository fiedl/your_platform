# This migration comes from workflow_kit (originally 20120721135535)
class CreateWorkflowKitWorkflows < ActiveRecord::Migration[4.2]
  def change
    create_table :workflow_kit_workflows do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
