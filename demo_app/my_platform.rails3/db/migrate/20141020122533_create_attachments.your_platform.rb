# This migration comes from your_platform (originally 20120814100529)
class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :file
      t.string :title
      t.text :description
      t.integer :parent_id
      t.string :parent_type

      t.timestamps
    end
  end
end
