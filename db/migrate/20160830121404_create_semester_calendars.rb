class CreateSemesterCalendars < ActiveRecord::Migration
  def change
    create_table :semester_calendars do |t|
      t.integer :group_id
      t.integer :year
      t.integer :term

      t.timestamps null: false
    end
  end
end
