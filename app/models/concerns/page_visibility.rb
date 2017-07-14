concern :PageVisibility do

  # Attention! This does not handle access rights.
  # Those are defined in `Ability`.
  # This merely checks filters unpublished or archived pages.

  included do

    # Some rules about page visibility:
    #
    # - A draft is invisible, except for its author.
    # - When previewing as user, ignore authorship, i.e. hide drafts.
    # - An archived page is invisible.
    #
    # Options:
    # - `preview_as`
    #
    scope :visible_to, -> (user, options = {}) {
      user = nil if options[:preview_as].to_s == 'user'
      # TODO: Use the new syntax when migrating to rails 5.
      # # (published.or.by_author(user)).not_archived
      Page.not_archived.where(id: (published.pluck(:id) + by_author(user).pluck(:id)))
    }

  end

  # Options:
  # - `preview_as`
  #
  def visible_to?(user, options = {})
    self.in? Page.visible_to(user, options)
  end

end