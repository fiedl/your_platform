class AddIndices < ActiveRecord::Migration
  def change
    add_index 'dag_links', [:ancestor_id, :ancestor_type, :direct], { name: 'dag_ancestor', order: { id: :asc } }
    add_index 'dag_links', [:descendant_id, :descendant_type], { name: 'dag_descendant', order: { id: :asc } }
  end
end
