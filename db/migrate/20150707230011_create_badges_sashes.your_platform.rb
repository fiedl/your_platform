# This migration comes from your_platform (originally 20150707222860)
class CreateBadgesSashes < ActiveRecord::Migration[4.2]
  def self.up
    create_table :badges_sashes do |t|
      t.integer :badge_id, :sash_id
      t.boolean :notified_user, default: false
      t.datetime :created_at
    end
    add_index :badges_sashes, [:badge_id, :sash_id]
    add_index :badges_sashes, :badge_id
    add_index :badges_sashes, :sash_id
  end

  def self.down
    drop_table :badges_sashes
  end
end
