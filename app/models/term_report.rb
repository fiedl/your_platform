class TermReport < ApplicationRecord
  default_scope { includes(:term).order('terms.year asc, terms.type asc') }

  belongs_to :term
  belongs_to :group

  has_many :member_entries, class_name: 'TermReportMemberEntry', dependent: :destroy
  has_many :states, as: :reference, dependent: :destroy

  after_create :fill_info

  def title
    "#{term.title}, #{group.title}"
  end

  def fill_info
    raise ActiveRecord::RecordInvalid, "term report has already been #{self.state.to_s}." if self.state && !(self.state.rejected?)
    self.number_of_members = group.memberships.at_time(end_of_term).count
    self.number_of_new_members = group.memberships.with_past.where(valid_from: term_time_range).count
    self.number_of_membership_ends = group.memberships.with_past.where(valid_to: term_time_range).count
    self.balance = number_of_new_members - number_of_membership_ends
    self.save
  end

  def end_of_term
    term.end_at
  end

  def term_time_range
    term.time_range
  end

  def year
    term.year
  end

  def submitted?
    submitted_at
  end

  def submitted_at
    states.where(name: "submitted").last.try(:created_at)
  end

  def submitted_by
    states.where(name: "submitted").last.try(:author)
  end

  def accepted?
    accepted_at
  end

  def accepted_at
    states.where(name: "accepted").last.try(:created_at)
  end

  def rejected?
    rejected_at
  end

  def rejected_state
    states.where(name: "rejected").last
  end

  def rejected_at
    rejected_state.try(:created_at)
  end

  def rejected_by
    rejected_state.try(:author)
  end

  def state
    states.last
  end

  def contributors
    states.collect(&:author).uniq
  end

  def due?
    (Time.zone.now >= due_at)
  end

  def due_at
    end_of_term.to_date
  end

  def too_old_to_submit?
    year < (Time.zone.now.year - 1)
  end

end



