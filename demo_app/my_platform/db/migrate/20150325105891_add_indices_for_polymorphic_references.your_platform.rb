# This migration comes from your_platform (originally 20150129194501)
class AddIndicesForPolymorphicReferences < ActiveRecord::Migration[4.2]
  def change
    add_index 'profile_fields', [:profileable_id, :profileable_type], { name: 'profileable', order: { profileable_id: :asc } }
    add_index 'profile_fields', [:profileable_id, :profileable_type, :type], { name: 'profileable_type', order: { profileable_id: :asc } }
    add_index 'profile_fields', [:type], { name: 'type' }

    add_index 'flags', [:flagable_id, :flagable_type], { name: 'flagable', order: { flagable_id: :asc } }
    add_index 'flags', [:flagable_id, :flagable_type, :key], { name: 'flagable_key', order: { flagable_id: :asc } }
    add_index 'flags', [:key], { name: 'key' }

    add_index 'nav_nodes', [:navable_id, :navable_type], { name: 'navable_type', order: { navable_id: :asc } }
  end
end
