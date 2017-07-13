concern :PageVisibility do

  # Attention! This does not handle access rights.
  # Those are defined in `Ability`.
  # This merely checks filters unpublished or archived pages.

  included do

    # Some rules about page visibility:
    #
    # - A draft is invisible, except for its author.
    # - An archived page is invisible.
    #
    scope :visible_to, -> (user) {
      # TODO: Use the new syntax when migrating to rails 5.
      # # (published.or.by_author(user)).not_archived
      Page.not_archived.where(id: (published.pluck(:id) + by_author(user).pluck(:id)))
    }

  end

  def visible_to?(user)
    self.in? Page.visible_to(user)
  end

end