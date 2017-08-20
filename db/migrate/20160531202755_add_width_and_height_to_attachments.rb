class AddWidthAndHeightToAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :attachments, :width, :integer
    add_column :attachments, :height, :integer
  end
end
