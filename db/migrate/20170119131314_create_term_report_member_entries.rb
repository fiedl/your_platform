class CreateTermReportMemberEntries < ActiveRecord::Migration
  def change
    create_table :term_report_member_entries do |t|
      t.integer :user_id
      t.integer :term_report_id

      t.string :last_name
      t.string :first_name
      t.string :name_affix
      t.string :date_of_birth
      t.string :primary_address
      t.string :secondary_address
      t.string :phone
      t.string :email
      t.string :profession

      t.string :category

      t.timestamps null: false
    end
  end
end
