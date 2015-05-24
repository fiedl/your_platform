class AddResponsibleAdminIdToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :responsible_admin_id, :integer
  end
end
