# This migration comes from your_platform (originally 20160518113650)
class AddBoxConfigurationToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :pages, :box_configuration, :text
  end
end
