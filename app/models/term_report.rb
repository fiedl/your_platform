class TermReport < ActiveRecord::Base
  default_scope { includes(:term).order('terms.year asc, terms.type asc') }

  belongs_to :term
  belongs_to :group

  has_many :member_entries, class_name: 'TermReportMemberEntry', dependent: :destroy

  after_create :fill_info

  def title
    "#{term.title}, #{group.title}"
  end

  def fill_info
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

end



