# This migration comes from workflow_kit (originally 20120721140613)
class CreateWorkflowKitParameters < ActiveRecord::Migration[4.2]
  def change
    create_table :workflow_kit_parameters do |t|
      t.string :key
      t.string :value
      t.references :parameterable, polymorphic: true

      t.timestamps
    end
  end
end
