class AddDomainToPages < ActiveRecord::Migration[5.0]
  def change
    add_column :pages, :domain, :string
  end
end
