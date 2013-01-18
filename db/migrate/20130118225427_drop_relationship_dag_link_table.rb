class DropRelationshipDagLinkTable < ActiveRecord::Migration
  def change
    drop_table :relationship_dag_links
  end
end
