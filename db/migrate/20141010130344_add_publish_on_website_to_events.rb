class AddPublishOnWebsiteToEvents < ActiveRecord::Migration
  def change
    add_column :events, :publish_on_global_website, :boolean
    add_column :events, :publish_on_local_website, :boolean
  end
end
