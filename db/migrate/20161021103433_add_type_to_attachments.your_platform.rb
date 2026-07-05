# This migration comes from your_platform (originally 20161020224959)
class AddTypeToAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :attachments, :type, :string
  end
end
