class CreateNavNodes < ActiveRecord::Migration
  def change
    create_table :nav_nodes do |t|
      t.string :url_component
      t.string :breadcrumb_item
      t.string :menu_item
      t.boolean :slim_breadcrumb
      t.boolean :slim_url
      t.boolean :slim_menu
      t.boolean :hidden_menu
      t.references :navable, polymorphic: true
#      t.integer :navable_id
#      t.string :navable_type

      t.timestamps
    end
  end
end
