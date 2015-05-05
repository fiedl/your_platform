# This migration comes from your_platform (originally 20141008101744)
class AddLocationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :location, :string
  end
end
