# This migration comes from your_platform (originally 20141018221659)
class AddAuthorToAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :attachments, :author_user_id, :integer
  end
end
