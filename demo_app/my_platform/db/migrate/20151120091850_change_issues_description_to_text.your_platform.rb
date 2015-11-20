# This migration comes from your_platform (originally 20151120071318)
class ChangeIssuesDescriptionToText < ActiveRecord::Migration
  def change
    change_table :issues do |t|
      t.change :description, :text
    end
  end
end
