class AddMoveFromAndToGroupIdsToWorkflows < ActiveRecord::Migration
  def change
    add_column :workflow_kit_workflows, :move_from_group_id, :integer
    add_column :workflow_kit_workflows, :move_to_group_id, :integer
  end
end
