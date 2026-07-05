# This migration comes from your_platform (originally 20131115114715)
class ValidityRangeForDagLinks < ActiveRecord::Migration[4.2]
  def up
    change_table :dag_links do |t|
      t.rename :deleted_at, :valid_to
      t.datetime :valid_from
      # This is not needed for fresh installs anymore.
      #
      # # DagLink.connection.execute "UPDATE `dag_links` SET `valid_from`=`created_at` WHERE 1"
    end
  end
  def down
    change_table :dag_links do |t|
      t.rename :valid_to, :deleted_at

      # This is not needed for fresh installs anymore.
      #
      # # DagLink.connection.execute "UPDATE `dag_links` SET `created_at`=`valid_from` WHERE `valid_from` IS NOT NULL"

      t.remove_column :valid_from
    end
  end
end
