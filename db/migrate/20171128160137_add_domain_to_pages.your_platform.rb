# This migration comes from your_platform (originally 20171128155201)
class AddDomainToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :domain, :string
  end
end
