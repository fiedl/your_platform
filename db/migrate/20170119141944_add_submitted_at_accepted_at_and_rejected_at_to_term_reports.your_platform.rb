# This migration comes from your_platform (originally 20170119141909)
class AddSubmittedAtAcceptedAtAndRejectedAtToTermReports < ActiveRecord::Migration[4.2]
  def change
    add_column :term_reports, :submitted_at, :datetime
    add_column :term_reports, :accepted_at, :datetime
    add_column :term_reports, :rejected_at, :datetime
  end
end
