class AddResponsibleAdminIdToIssues < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :responsible_admin_id, :integer
  end
end
