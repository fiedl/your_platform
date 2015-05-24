class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.string :title
      t.string :description
      t.integer :reference_id
      t.string :reference_type
      t.datetime :resolved_at

      t.timestamps null: false
    end
  end
end
