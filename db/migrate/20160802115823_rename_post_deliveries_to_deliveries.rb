class RenamePostDeliveriesToDeliveries < ActiveRecord::Migration
  def change
    rename_table :post_deliveries, :deliveries
    rename_column :deliveries, :post_id, :deliverable_id
    add_column :deliveries, :deliverable_type, :string
    Delivery.update_all deliverable_type: 'Post'
    add_column :deliveries, :message_id, :string
    add_column :deliveries, :subject, :string
  end
end
