# This migration comes from your_platform (originally 20131115114715)
class ValidityRangeForDagLinks < ActiveRecord::Migration
  def up
    change_table :dag_links do |t|
      t.rename :deleted_at, :valid_to
      t.datetime :valid_from
    end
  end
  def down
    change_table :dag_links do |t|
      t.rename :valid_to, :deleted_at
      t.remove_column :valid_from
    end
  end
end
