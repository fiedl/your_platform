class RenameTermInfosToTermReports < ActiveRecord::Migration
  def change
    rename_table :term_infos, :term_reports
  end
end
