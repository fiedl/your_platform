class CreateStatusGroupMembershipInfos < ActiveRecord::Migration[4.2]
  def change
    create_table :status_group_membership_infos do |t|
      t.integer :membership_id
      t.integer :promoted_by_workflow_id
      t.integer :promoted_on_event_id

      t.timestamps
    end
  end
end
