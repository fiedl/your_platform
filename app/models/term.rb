class Term < ApplicationRecord
  has_many :term_reports

  validates :year, uniqueness: {scope: :type}

  default_scope { order('year asc, type asc') }

  scope :current, -> {
    where(type: ["Terms::Winter", "Terms::Summer"])
    .where(year: (Time.zone.now.year - 1)..(Time.zone.now.year + 1)).select { |term|
      term.current?
    }
  }

  def time_range
    start_at..end_at
  end

  def officer_valuation_date
    end_at - 20.days
  end

  def current?
    time_range.cover? Time.zone.now
  end

  def to_s
    title
  end

  def self.by_year_and_type(year, type)
    self.find_or_create_by(year: year, type: type)
  end

  def self.by_date(date)
    where(year: date.year, type: ["Terms::Winter", "Terms::Summer"]).all.detect { |term| term.time_range.cover? date }
  end

  def self.first_or_create_current
    # For cases where the terms do not exist, yet,
    # those types will be created:
    Term.by_year_and_type(Time.zone.now.year - 1, "Terms::Winter") # winter term may begin in the previous year
    Term.by_year_and_type(Time.zone.now.year, "Terms::Winter")
    Term.by_year_and_type(Time.zone.now.year, "Terms::Summer")

    self.current.first
  end

  def self.current!
    first_or_create_current
  end

  def as_json(*args)
    super.merge({
      title: title,
      start_at: start_at,
      end_at: end_at,
      type: type
    })
  end

end
