class CorporationScore < TermReports::ForCorporation

  def title
    corporation.title
  end

  def fill_score_info
    self.number_of_status_changes = status_changes.count
    self.number_of_good_events = good_events.count
    self.number_of_events_with_pictures = events_with_pictures.count
    self.number_of_semester_calendars = semester_calendars.count
    self.number_of_semester_calendar_pdfs = semester_calendar_pdfs.count
    self.number_of_current_officers = current_officers.count
    self.number_of_documents = current_documents.count
    self.number_of_good_member_profiles = good_member_profiles.count
    self.number_of_current_member_profiles = current_member_profiles.count
    self.score = total_score
    self.save
    self
  end

  def scope
    corporation
  end

  def status_changes
    scope.status_groups.collect do |status_group|
      status_group.memberships.direct.where(valid_to: self.term.time_range)
    end.flatten
  end

  def good_events
    events.select do |event|
      event.public? && (event.location.to_s.length > 10)
    end
  end

  def events_with_pictures
    events.select do |event|
      event.attachments.count > 0
    end
  end

  def semester_calendars
    corporation.semester_calendars.where(year: term.year, term: term.to_enum)
  end

  def semester_calendar_pdfs
    semester_calendars.map(&:attachments).flatten
  end

  def current_officers
    Membership.direct.where(valid_from: (term.time_range.min - 2.months)..term.time_range.max, ancestor_id: scope.officers_groups_of_self_and_descendant_groups.map(&:id))
  end

  def current_documents
    Attachment.where(created_at: term.time_range, parent_type: "Page",
        parent_id: (scope.descendant_pages.pluck(:id) + events.collect { |event| event.descendant_pages.pluck(:id) }.flatten))
  end

  def good_member_profiles
    scope.members.select { |member| member.profile_fields.count >= 27 }
  end

  def current_member_profiles
    scope.members.select { |member| member.profile_fields.where(updated_at: (term.time_range.min - 6.months)..term.time_range.max).any? }
  end

  def self.score_columns
    [:new_members_score, :status_changes_score, :events_score, :good_events_score,
      :events_with_pictures_score, :semester_calendar_score, :semester_calendar_pdf_score,
      :current_officers_score, :documents_score, :good_member_profiles_score, :current_member_profiles_score,
      :total_score]
  end

  def new_members_score
    number_of_new_members
  end

  def status_changes_score
    number_of_status_changes / 5
  end

  def events_score
    number_of_events / 6
  end

  def good_events_score
    number_of_good_events / 3
  end

  def events_with_pictures_score
    number_of_events_with_pictures / 3
  end

  def semester_calendar_score
    (number_of_semester_calendars == 1) ? 1 : 0
  end

  def semester_calendar_pdf_score
    (number_of_semester_calendar_pdfs > 0) ? 1 : 0
  end

  def current_officers_score
    number_of_current_officers / 4
  end

  def documents_score
    number_of_documents / 3
  end

  def good_member_profiles_score
    if scope.members.any?
      number_of_good_member_profiles * 5 / scope.members.count
    else
      0
    end
  end

  def current_member_profiles_score
    if scope.members.any?
      number_of_current_member_profiles * 5 / scope.members.count
    else
      0
    end
  end

  def total_score
    sum = 0
    (self.class.score_columns - [:total_score]).each { |column| sum += self.send column }
    return sum
  end

end