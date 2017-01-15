class Term < ActiveRecord::Base
  has_many :term_infos

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

end
