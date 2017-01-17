class TermInfo < ActiveRecord::Base
  default_scope { includes(:term).order('terms.year asc, terms.type asc') }

  belongs_to :term
  belongs_to :corporation

  after_create :fill_info

  def semester_calendar
    corporation.semester_calendars.find_by year: term.year, term: term.to_enum
  end

  def fill_info
    self.number_of_events = semester_calendar.try(:events).try(:count)
    self.number_of_members = corporation.memberships_for_member_list.at_time(end_of_term).count
    self.number_of_new_members = corporation.memberships.with_past.where(valid_from: term_time_range).count
    self.number_of_membership_ends = corporation.former_members_memberships.where(valid_from: term_time_range).count
    self.number_of_deaths = corporation.deceased.memberships.with_past.where(valid_from: term_time_range).count
    self.save
  end

  def self.by_corporation_and_term(corporation, term)
    self.find_or_create_by(corporation_id: corporation.id, term_id: term.id)
  end

  def end_of_term
    term.end_at
  end

  def term_time_range
    term.time_range
  end
end



