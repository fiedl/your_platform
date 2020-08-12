class AddPublishOnPublicWebsiteToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :publish_on_public_website, :boolean
  end
end
