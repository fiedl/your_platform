# This represents corporation events grouped by semester.
#
#       1 Jan |
#       2 Feb |
#       3 Mrz -
#       4 Apr |
#       5 Mai |
#       6 Jun | Sommersemester
#       7 Jul |
#       8 Aug |
#       9 Sep -
#      10 Okt |
#      11 Nov | Wintersemester
#      12 Dez |
#
class SemesterCalendar < ActiveRecord::Base
  belongs_to :group
  enum term: [:winter_term, :summer_term]

  has_many :attachments, as: :parent, dependent: :destroy

  # # This does not work in rails 4. TODO: Re-check in rails 5.
  # has_many :events, -> (semester_calendar) { where(start_at: semester_calendar.current_terms_time_range) }, through: :group, source: :descendant_events
  # accepts_nested_attributes_for :events

  def title(options = {})
    locale = options[:locale] || I18n.default_locale
    "#{term_to_s(locale)} #{year_to_s}"
  end

  def term_to_s(locale)
    I18n.with_locale locale do
      I18n.translate (term || :winter_term)
    end
  end

  def year_to_s
    if summer_term?
      year.to_s
    else
      "#{year.to_s}/#{(year + 1).to_s.last(2)}"
    end
  end

  def events(reload = false)
    @events = nil if reload
    @events ||= group.events.where(start_at: current_terms_time_range).order(:start_at).to_a
  end

  def events_attributes=(attributes)
    attributes.each do |i, event_params|
      if event_params[:id].present?
        event = events.select { |event| event.id == event_params[:id].to_i }.first
        if event
          if event_params[:_destroy] == '1'
            event.destroy # http://railscasts.com/episodes/196-nested-model-form-revised
          else
            event.update_attributes event_params.except(:_destroy, :id)
          end
        else
          raise("event #{event_params[:id]} not found.")
        end
      else
        new_event = Event.create(event_params.except(:_destroy).merge({group_id: group.id}))
        events.push(new_event)
      end
    end
  end

  def save(*args)
    super(*args)
    self.events.map(&:save)
  end

  def update_attributes(attributes)
    self.events_attributes = attributes[:events_attributes] if attributes[:events_attributes]
    self.save
    super(attributes.except(:events_attributes))
  end

  def current_terms_time_range
    if summer_term?
      summer_term_start..summer_term_end
    else
      winter_term_start..winter_term_end
    end
  end

  # def summer_term?
  #   Time.zone.now.month.in? 3..8
  # end
  def summer_term_start
    Time.zone.now.change(month: 3, day: 1, year: year)
  end
  def summer_term_end
    Time.zone.now.change(month: 8, day: 31, year: year)
  end
  def summer_term_range
    summer_term_start..summer_term_end
  end
  def winter_term_start
    Time.zone.now.change(month: 9, day: 1, year: year)
  end
  def winter_term_end
    Time.zone.now.change(month: 2, day: 28, year: year + 1)
  end
  def winter_term_range
    winter_term_start..winter_term_end
  end

  def president
    officer(:president)
  end

  def officer_group(key)
    group.officers_groups_of_self_and_descendant_groups.select { |g| g.has_flag? key }.first
  end

  def officer(key)
    officer_group(key).memberships.at_time(officer_valuation_date).first.user
  end

  def officer_valuation_date
    @officer_valuation_date ||= if summer_term?
      summer_term_end - 20.days
    else
      winter_term_end - 20.days
    end
  end

  def self.all_public_events_for(params = {})
    time_range = SemesterCalendar.new(params).current_terms_time_range
    Event.where(publish_on_global_website: true, start_at: time_range)
  end

  def self.current_term
    if self.new(year: Time.zone.now.year).summer_term_range.cover? Time.zone.now
      :summer_term
    else
      :winter_term
    end
  end

end