class ValidityRangeForDagLinks < ActiveRecord::Migration
  def up
    change_table :dag_links do |t|
      t.rename :deleted_at, :valid_to
      t.datetime :valid_from
      #DagLink.connection.execute "UPDATE `dag_links` SET `valid_from`=`created_at` WHERE 1"
    end
  end
  def down
    change_table :dag_links do |t|
      t.rename :valid_to, :deleted_at
      #DagLink.connection.execute "UPDATE `dag_links` SET `created_at`=`valid_from` WHERE `valid_from` IS NOT NULL"   
      t.remove_column :valid_from
    end
  end
end
