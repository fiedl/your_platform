class ChangeIssuesDescriptionToText < ActiveRecord::Migration
  def change
    change_table :issues do |t|
      t.change :description, :text
    end
  end
end
