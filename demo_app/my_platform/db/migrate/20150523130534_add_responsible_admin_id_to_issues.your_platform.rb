# This migration comes from your_platform (originally 20150523130511)
class AddResponsibleAdminIdToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :responsible_admin_id, :integer
  end
end
