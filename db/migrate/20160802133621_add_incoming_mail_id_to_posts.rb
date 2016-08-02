class AddIncomingMailIdToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :incoming_mail_id, :integer
  end
end
