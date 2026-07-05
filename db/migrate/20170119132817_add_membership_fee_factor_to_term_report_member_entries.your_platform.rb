class AddMembershipFeeFactorToTermReportMemberEntries < ActiveRecord::Migration[4.2]
  def change
    add_column :term_report_member_entries, :membership_fee_factor, :float
  end
end
