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
class SemesterCalendar < ApplicationRecord
  belongs_to :group
  belongs_to :term

  has_many :attachments, as: :parent, dependent: :destroy

  # # This does not work in rails 4. TODO: Re-check in rails 5.
  # has_many :events, -> (semester_calendar) { where(start_at: semester_calendar.current_terms_time_range) }, through: :group, source: :descendant_events
  # accepts_nested_attributes_for :events

  scope :current, -> { where(term_id: Term.current.map(&:id)) }

  def attachment=(file)
    attachments.create file: file
  end

  def current?
    term.time_range.cover? Time.zone.now
  end

  def title
    term.title
  end

  def term_to_s(locale)
    I18n.with_locale locale do
      I18n.translate (term || :winter_term)
    end
  end

  def year
    term.year
  end

  def year_to_s
    if summer_term?
      year.to_s
    else
      "#{year.to_s}/#{(year + 1).to_s.last(2)}"
    end
  end

  def summer_term?
    term.kind_of? Terms::Summer
  end


  def events
    group.events_with_subgroups.where(start_at: term.time_range).order(:start_at)
  end

  def important_events
    events.important
  end

  def commers
    events.commers.first
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
          raise(RuntimeError, "event #{event_params[:id]} not in semester calendar events.")
        end
      else
        if event_params[:name].present?
          new_event = Event.create(event_params.except(:_destroy).merge({group_id: group.id}))
          events.push(new_event)
        else
          Rails.logger.warn "Skipping creation of event without name: #{event_params.to_s}"
        end
      end
    end
    self.touch unless attributes.empty?
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

  def president
    officer(:president)
  end

  def officer_group(key)
    group.officers_groups_of_self_and_descendant_groups.select { |g| g.has_flag? key }.first
  end

  def officer(key)
    officer_group(key).memberships.at_time(officer_valuation_date).first.try(:user) if officer_group(key)
  end

  def officer_valuation_date
    term.officer_valuation_date
  end

  def self.by_corporation_and_term(corporation, term)
    self.find_or_create_by(group_id: corporation.id, term_id: term.id)
  end

end