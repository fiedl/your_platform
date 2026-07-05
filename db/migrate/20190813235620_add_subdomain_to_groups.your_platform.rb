# This migration comes from your_platform (originally 20190813235148)
class AddSubdomainToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :subdomain, :string
  end
end
