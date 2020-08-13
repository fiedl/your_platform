class Event < ApplicationRecord

  validates :start_at, presence: true
  before_validation -> { self.start_at ||= self.created_at || Time.zone.now }

  has_dag_links ancestor_class_names: %w(Group Page), descendant_class_names: %w(Group Page Post), link_class_name: 'DagLink'
  has_many :attachments, as: :parent, dependent: :destroy

  scope :important, -> { where(publish_on_global_website: true) }
  scope :commers, -> { where("name like ? or name like ?", "%commers%", "%kommers%") }
  scope :wartburgfest, -> { where("name like ?", "%wartburgfest%") }
  scope :wingolfsseminar, -> { where("name like ?", "%wingolfsseminar%") }


  include Structureable
  include EventGraph
  include Navable
  include EventGroups
  include EventContactPeople
  include EventAttendees
  include EventAvatar


  # General Properties
  # ==========================================================================================

  def as_json(options = {})
    super(options).merge({
      group_id: group_id,
      # contact_person_id: contact_person_id  # FIXME: Add this back when we have a more performant association for contact people.
    })
  end

  # The title, i.e. the caption of the event is its name.
  def title
    name
  end

  def to_param
    if start_at
      "#{id} #{name} #{start_at.year}-#{start_at.month}-#{start_at.day}".parameterize
    else
      "#{id} #{name}".parameterize
    end
  end

  def public?
    publish_on_local_website || publish_on_global_website
  end

  # This is used to find the event's place in the navigational structure.
  #
  def parent
    self.group
  end
  def parents
    parent ? [parent] : []
  end

  def empty?
    empty_title? && empty_description? && empty_attendees?
  end

  def non_empty?
    (! empty_description?) || (! empty_title?) || (! empty_attendees?)
  end

  def empty_title?
    self.name.in? [nil, "", I18n.t(:enter_name_of_event_here), "Neue Veranstaltung"]
  end

  def empty_description?
    self.description.blank?
  end

  def empty_attendees?
    not self.find_attendees_group.try(:members).try(:any?)
  end

  def group_name
    self.group.try(:name)
  end

  def corporation_name
    self.group.try(:corporation).try(:name)
  end

  def corporation_id
    self.group.try(:corporation).try(:id)
  end

  def contact_name
    self.contact_person.try(:title)
  end

  def contact_id
    self.contact_person.try(:id)
  end

  def avatar_url
    self.group.try(:avatar_url) || self.group.try(:corporation).try(:avatar_url)
  end

  def groups
    Group.where(id: [group_id] + parent_group_ids)
  end

  def corporations
    groups.map(&:corporation) - [nil]
  end


  # Times
  # ==========================================================================================

  def localized_start_at
    I18n.localize start_at if start_at.present?
  end
  def localized_start_at=(string)
    attribute_will_change! :start_at
    self.start_at = string.present? ? LocalizedDateTimeParser.parse(string, Time).to_time : nil
  end

  def localized_end_at
    I18n.localize end_at if end_at.present?
  end
  def localized_end_at=(string)
    attribute_will_change! :end_at
    self.end_at = string.present? ? LocalizedDateTimeParser.parse(string, Time).to_time : nil
  end

  def term
    Term.by_date start_at
  end

  def semester_calendars
    SemesterCalendar.where(group_id: corporations, term_id: term) if corporations.any? && term
  end

  def semester_calendar
    semester_calendars.first
  end
  def semester_calendar!
    semester_calendars.first_or_create
  end


  # Scopes
  # ==========================================================================================

  # We used to define `upcoming` as "from now on", i.e. `start_time > Time.zone.now`.
  # However, it is more convenient to see events that are currently in progress.
  # Therefore, redefining `upcoming` to hide events on the next day.#
  #
  #        yesterday  -----  today  ----  tomorrow
  #                              |= event, today, 20h
  #                         |--------------------------------------->  (upcoming)
  #
  # For events that are ongoing, e.g. started yesterday, but end tomorrow, we'll include
  # these events this scope in order to show them as long as they might be interesting.
  #
  #        yesterday  -----  today  ----  tomorrow
  #            |= event, yesterday to tomorrow =|
  #                         |--------------------------------------->  (upcoming)
  #
  # Date.today.to_datetime is 0h.
  #
  scope :upcoming, lambda { where("(start_at > ? AND end_at IS NULL) OR (end_at IS NOT NULL AND end_at > ?)", Date.today.to_datetime, Date.today.to_datetime) }

  def upcoming?
    Event.upcoming.pluck(:id).include? self.id
  end


  # Finder Methods
  # ==========================================================================================

  def self.find_all_by_user(user)
    ids = user.groups.collect { |g| g.events.pluck(:id) }.flatten
    ids += user.ancestor_event_ids
    self.where(id: ids.uniq).order(:start_at)
  end


  # Calendar Export
  # ==========================================================================================

  def to_icalendar_event
    e = Icalendar::Event.new
    if self.start_at
      e.dtstart = Icalendar::Values::DateTime.new(self.start_at.utc, tzid: 'UTC')
      e.dtend = Icalendar::Values::DateTime.new((self.end_at || self.start_at + 1.hour).utc, tzid: 'UTC')
    end
    e.summary = self.name
    e.description = self.description
    e.location = self.location
    if self.contact_people.first.try(:email).present?
      e.organizer = self.contact_people.first.email
      e.organizer.ical_params = {'CN' => self.contact_people.first.title}
    end
    e.url = self.url
    e.uid = e.url
    e.created = Icalendar::Values::DateTime.new(self.created_at.utc, tzid: 'UTC')
    e.last_modified = Icalendar::Values::DateTime.new(self.updated_at.utc, tzid: 'UTC')
    return e
  end

  def to_icalendar
    cal = Icalendar::Calendar.new
    cal.add_event self.to_icalendar_event
    cal.publish
    return cal
  end

  def to_ics
    self.to_icalendar.to_ical
  end

  def to_ical
    self.to_ics
  end

  # Example:
  #     Group.find(12).events.to_ics
  #
  def self.to_ics
    self.to_icalendar.to_ical
  end

  def self.to_icalendar
    cal = Icalendar::Calendar.new
    self.all.each do |event|
      cal.add_event event.to_icalendar_event
    end
    cal.publish
    return cal
  end

  def self.to_ical
    self.to_ics
  end

  include EventCaching if use_caching?
end
