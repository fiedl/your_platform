# This migration comes from your_platform (originally 20151120071318)
class ChangeIssuesDescriptionToText < ActiveRecord::Migration[4.2]
  def change
    change_table :issues do |t|
      t.change :description, :text
    end
  end
end
