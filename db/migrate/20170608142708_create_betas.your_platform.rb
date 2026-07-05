# This migration comes from your_platform (originally 20170608134552)
class CreateBetas < ActiveRecord::Migration[4.2]
  def change
    create_table :betas do |t|
      t.string :title
      t.integer :max_invitations_per_inviter

      t.timestamps null: false
    end
  end
end
