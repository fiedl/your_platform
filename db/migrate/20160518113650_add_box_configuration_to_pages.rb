class AddBoxConfigurationToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :box_configuration, :text
  end
end
