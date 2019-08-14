class AddSubdomainToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :subdomain, :string
  end
end
