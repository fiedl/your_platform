# This migration comes from your_platform (originally 20141202140522)
class AddIndices < ActiveRecord::Migration[4.2]
  def change
    add_index 'dag_links', [:ancestor_id, :ancestor_type, :direct], { name: 'dag_ancestor', order: { id: :asc } }
    add_index 'dag_links', [:descendant_id, :descendant_type], { name: 'dag_descendant', order: { id: :asc } }
  end
end
