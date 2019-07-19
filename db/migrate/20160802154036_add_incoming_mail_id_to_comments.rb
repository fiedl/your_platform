class AddIncomingMailIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :incoming_mail_id, :integer
  end
end
