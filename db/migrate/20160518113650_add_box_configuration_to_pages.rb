class AddBoxConfigurationToPages < ActiveRecord::Migration
  def change
    add_column :pages, :box_configuration, :text
  end
end
