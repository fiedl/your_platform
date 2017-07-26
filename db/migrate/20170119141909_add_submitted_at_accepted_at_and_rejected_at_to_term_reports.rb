class AddSubmittedAtAcceptedAtAndRejectedAtToTermReports < ActiveRecord::Migration[4.2]
  def change
    add_column :term_reports, :submitted_at, :datetime
    add_column :term_reports, :accepted_at, :datetime
    add_column :term_reports, :rejected_at, :datetime
  end
end
