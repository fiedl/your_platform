class CreateBetas < ActiveRecord::Migration
  def change
    create_table :betas do |t|
      t.string :title
      t.integer :max_invitations_per_inviter

      t.timestamps null: false
    end
  end
end
