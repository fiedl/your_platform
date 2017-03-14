class Event < ActiveRecord::Base
  attr_accessible :description, :location, :end_at, :name, :start_at, :localized_start_at, :localized_end_at, :publish_on_local_website, :publish_on_global_website, :group_id, :contact_person_id if defined? attr_accessible

  is_structureable ancestor_class_names: %w(Group Page), descendant_class_names: %w(Group Page)
  is_navable

  has_many :attachments, as: :parent, dependent: :destroy


  include EventGroups
  include EventContactPeople
  include EventAttendees


  # General Properties
  # ==========================================================================================

  def as_json(options = {})
    super(options).merge({
      group_id: group_id
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
    self.name.in? [nil, "", I18n.t(:enter_name_of_event_here)]
  end

  def empty_description?
    self.description.blank?
  end

  def empty_attendees?
    not self.find_attendees_group.try(:members).try(:any?)
  end


  # Times
  # ==========================================================================================

  def localized_start_at
    I18n.localize start_at.to_time if start_at.present?
  end
  def localized_start_at=(string)
    attribute_will_change! :start_at
    self.start_at = string.present? ? LocalizedDateTimeParser.parse(string, Time).to_time : nil
  end

  def localized_end_at
    I18n.localize end_at.to_time if end_at.present?
  end
  def localized_end_at=(string)
    attribute_will_change! :end_at
    self.end_at = string.present? ? LocalizedDateTimeParser.parse(string, Time).to_time : nil
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


  # Existance
  # ==========================================================================================

  # For some strange reason, the callbacks of the creation of an event appear to
  # prevent the event form being found in the database after its creation.
  #
  # In the EventsController and in specs, we need to make sure that the event exists
  # before continuing. Otherwise `ActiveRecord::RecordNotFound` is raised in the controller
  # or when redirecting to the event.
  #
  # This still exists in Rails 4.
  # TODO: Check if this is still necessary when migrating to Rails 5.
  #
  def wait_for_me_to_exist
    raise 'The event has no id, yet!' unless id
    begin
      Event.find self.id
    rescue ActiveRecord::RecordNotFound => e
      sleep 1
      retry
    end
  end

  include EventCaching if use_caching?
end
