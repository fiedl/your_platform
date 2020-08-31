class SupportRequest < Post

  default_scope { includes(:parent_groups).where(groups: {id: Group.support}) }
  scope :solved, -> { flagged(:solved) }
  scope :unsolved, -> { not_flagged(:solved) }

  def solved?
    has_flag? :solved
  end

  def mark_as_solved
    add_flag :solved
  end

end