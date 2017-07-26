class AddPublishOnWebsiteToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :publish_on_global_website, :boolean
    add_column :events, :publish_on_local_website, :boolean
  end
end
