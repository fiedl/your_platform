# This migration comes from your_platform (originally 20170114205213)
class CreateTerms < ActiveRecord::Migration
  def change
    create_table :terms do |t|
      t.integer :year
      t.integer :term

      t.timestamps null: false
    end
  end
end
