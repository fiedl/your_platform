class RenameTermInfosToTermReports < ActiveRecord::Migration[4.2]
  def change
    rename_table :term_infos, :term_reports
  end
end
