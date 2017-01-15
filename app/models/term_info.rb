class TermInfo < ActiveRecord::Base
  belongs_to :term
  belongs_to :corporation

  delegate :current_terms_time_range, to: :semester_calendar

  def semester_calendar
    corporation.semester_calendars.find_by year: term.year, term: term.to_enum
  end

  def fill_info
    self.number_of_events = semester_calendar.events.count
    self.number_of_members = corporation.memberships_for_member_list.at_time(current_terms_time_range.last).count
    self.number_of_new_members = corporation.memberships.with_past.where(valid_from: current_terms_time_range).count
    self.number_of_membership_ends = corporation.memberships.with_past.where(valid_to: current_terms_time_range).count
    self.number_of_deaths = corporation.deceased.memberships.with_past.where(valid_from: current_terms_time_range).count
    self.save
  end
end



