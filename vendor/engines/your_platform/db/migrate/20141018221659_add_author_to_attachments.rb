class AddAuthorToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :author_user_id, :integer
  end
end
