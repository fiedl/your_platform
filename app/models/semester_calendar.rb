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
class SemesterCalendar
  include ActiveModel::Model

  attr_accessor :group

  def initialize(group)
    @group = group
  end

  def id
    group.id
  end

  def save
    events.map(&:save)
  end

  def events
    @events ||= group.events.where(start_at: current_terms_time_range).to_a
  end

  def events_attributes=(attributes)
    attributes.each do |i, event_params|
      if event_params[:id].present?
        events.select { |event| event.id == event_params[:id].to_i }.first.attributes = event_params
      else
        events.push(Event.new(event_params))
      end
    end
  end

  def update_attributes(attributes)
    self.events_attributes = attributes[:events_attributes]
    self.save
  end

  def current_terms_time_range
    if summer_term?
      summer_term_start..summer_term_end
    else
      winter_term_start..winter_term_end
    end
  end

  def summer_term?
    Time.zone.now.month.in? 3..8
  end
  def summer_term_start
    Time.zone.now.change(month: 3, day: 1)
  end
  def summer_term_end
    Time.zone.now.change(month: 8, day: 31)
  end
  def winter_term_start
    Time.zone.now.change(month: 9, day: 1)
  end
  def winter_term_end
    Time.zone.now.change(month: 2, day: 28)
  end


end