class AddKlammerungAndWNummerToTermReportMemberEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :term_report_member_entries, :klammerung, :string
    add_column :term_report_member_entries, :w_nummer, :string
  end
end
