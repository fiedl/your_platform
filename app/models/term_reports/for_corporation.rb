class TermReports::ForCorporation < TermReport

  def corporation
    group
  end

  def semester_calendar
    corporation.semester_calendars.find_by term_id: term.id
  end

  def fill_info
    raise ActiveRecord::RecordInvalid, "term report has already been #{self.state.to_s}." if self.state
    self.delete_cache
    self.number_of_events = events.count
    self.number_of_members = corporation.memberships_for_member_list.at_time(end_of_term).count
    self.number_of_new_members = corporation.memberships.with_past.where(valid_from: term_time_range).count
    self.number_of_membership_ends = corporation.former_members_memberships.where(valid_from: term_time_range).count
    self.number_of_deaths = corporation.deceased.memberships.with_past.where(valid_from: term_time_range).count
    self.balance = number_of_new_members - number_of_membership_ends - number_of_deaths
    self.save

    self.becomes(CorporationScore).fill_score_info
  end

  def self.by_corporation_and_term(corporation, term)
    self.find_or_create_by(group_id: corporation.id, term_id: term.id)
  end

  def officer_group(key)
    group.officers_groups_of_self_and_descendant_groups.select { |g| g.has_flag? key }.first
  end

  def officer(key)
    officer_group(key).memberships.at_time(end_of_term).order(:valid_from).first.try(:user) if officer_group(key)
  end

  def events
    semester_calendar.try(:events) || []
  end

end



