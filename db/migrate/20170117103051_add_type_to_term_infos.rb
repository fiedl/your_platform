class AddTypeToTermInfos < ActiveRecord::Migration
  def change
    add_column :term_infos, :type, :string
    rename_column :term_infos, :corporation_id, :group_id
  end
end
