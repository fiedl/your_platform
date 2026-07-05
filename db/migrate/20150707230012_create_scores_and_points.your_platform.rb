# This migration comes from your_platform (originally 20150707222861)
class CreateScoresAndPoints < ActiveRecord::Migration[4.2]
  def change
    create_table :merit_scores do |t|
      t.references :sash
      t.string :category, default: 'default'
    end

    create_table :merit_score_points do |t|
      t.references :score
      t.integer :num_points, default: 0
      t.string :log
      t.datetime :created_at
    end
  end
end
