# This migration comes from your_platform (originally 20170117103051)
class AddTypeToTermInfos < ActiveRecord::Migration[4.2]
  def change
    add_column :term_infos, :type, :string
    rename_column :term_infos, :corporation_id, :group_id
  end
end
