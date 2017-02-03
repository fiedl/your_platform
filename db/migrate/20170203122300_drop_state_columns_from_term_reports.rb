class DropStateColumnsFromTermReports < ActiveRecord::Migration
  def change
    remove_column :term_reports, :submitted_at
    remove_column :term_reports, :accepted_at
    remove_column :term_reports, :rejected_at
  end
end
