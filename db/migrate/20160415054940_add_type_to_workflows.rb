class AddTypeToWorkflows < ActiveRecord::Migration
  def change
    add_column :workflow_kit_workflows, :type, :string
  end
end
