class AddTermIdToSemesterCalendarsAndMigrate < ActiveRecord::Migration
  def up
    rename_column :semester_calendars, :term, :term_type
    add_column :semester_calendars, :term_id, :integer
    SemesterCalendar.all.each do |semester_calendar|
      type = (semester_calendar.term_type == 0) ? "Terms::Winter" : "Terms::Summer"
      SemesterCalendar.where(id: semester_calendar.id).update_all term_id: Term.by_year_and_type(semester_calendar.read_attribute(:year), type)
    end
    remove_column :semester_calendars, :year
    remove_column :semester_calendars, :term_type
  end
  def down
    add_column :semester_calendars, :term_type, :integer
    add_column :semester_calendars, :year, :integer
    SemesterCalendar.all.each do |semester_calendar|
      term = Term.find(semester_calendar.read_attribute(:term_id))
      type = term.kind_of?(Terms::Summer) ? 1 : 0
      SemesterCalendar.where(id: semester_calendar.id).update_all term_type: type, year: term.year
    end
    rename_column :semester_calendars, :term_type, :term
    remove_column :semester_calendars, :term_id
  end
end
