# This migration comes from your_platform (originally 20170119075855)
class RenameTermInfosToTermReports < ActiveRecord::Migration
  def change
    rename_table :term_infos, :term_reports
  end
end
