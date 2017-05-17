class AddScoreColumnsToTermReports < ActiveRecord::Migration
  def change
    add_column :term_reports, :number_of_status_changes, :integer
    add_column :term_reports, :number_of_good_events, :integer
    add_column :term_reports, :number_of_events_with_pictures, :integer
    add_column :term_reports, :number_of_semester_calendars, :integer
    add_column :term_reports, :number_of_semester_calendar_pdfs, :integer
    add_column :term_reports, :number_of_current_officers, :integer
    add_column :term_reports, :number_of_documents, :integer
    add_column :term_reports, :number_of_good_member_profiles, :integer
    add_column :term_reports, :number_of_current_member_profiles, :integer
    add_column :term_reports, :score, :decimal
  end
end
