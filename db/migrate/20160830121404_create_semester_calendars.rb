class CreateSemesterCalendars < ActiveRecord::Migration[4.2]
  def change
    create_table :semester_calendars do |t|
      t.integer :group_id
      t.integer :year
      t.integer :term

      t.timestamps null: false
    end
  end
end
