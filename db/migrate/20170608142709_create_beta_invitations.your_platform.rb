# This migration comes from your_platform (originally 20170608142111)
class CreateBetaInvitations < ActiveRecord::Migration[4.2]
  def change
    create_table :beta_invitations do |t|
      t.integer :beta_id
      t.integer :inviter_id
      t.integer :invitee_id

      t.timestamps null: false
    end
  end
end
