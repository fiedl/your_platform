class AddContentTypeAndFileSizeToAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :attachments, :content_type, :string
    add_column :attachments, :file_size, :integer
  end
end
