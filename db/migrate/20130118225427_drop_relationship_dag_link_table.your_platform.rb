class DropRelationshipDagLinkTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :relationship_dag_links
  end
end
