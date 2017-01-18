class Term < ActiveRecord::Base
  has_many :term_infos

  validates :year, uniqueness: {scope: :type}

  default_scope { order('year asc, type asc') }

  scope :current, -> {
    where(year: Time.zone.now.year..(Time.zone.now.year + 1)).select { |term|
      term.current?
    }
  }

  def time_range
    start_at..end_at
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

end
