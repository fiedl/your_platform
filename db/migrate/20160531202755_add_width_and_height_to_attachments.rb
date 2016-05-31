class AddWidthAndHeightToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :width, :integer
    add_column :attachments, :height, :integer
  end
end
