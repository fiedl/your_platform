concern :PageVisibility do

  # Attention! This does not handle access rights.
  # Those are defined in `Ability`.
  # This merely checks filters unpublished or archived pages.

  included do

    # Some rules about page visibility:
    #
    # - A draft is invisible, except for its author and its officers.
    # - When previewing as user, ignore authorship, i.e. hide drafts.
    # - An archived page is invisible.
    #
    # Options:
    # - `preview_as`
    #
    scope :visible_to, -> (user, options = {}) {
      user = nil if options[:preview_as].to_s == 'user'
      visible_based_on_published(user)
          .visible_based_on_archived(user)
          .visible_based_on_public_or_intranet(user)
    }
    scope :visible_based_on_published, -> (user) { published.or(by_author(user)).or(by_officers(user)) }
    scope :visible_based_on_archived, -> (user) { not_archived }
    scope :visible_based_on_public_or_intranet, -> (user) { user ? all : public_websites }

    scope :by_officers, -> (user) { user ? where(id: user.page_ids_of_pages_the_user_is_officer_of) : none }

  end

  # Options:
  # - `preview_as`
  #
  def visible_to?(user, options = {})
    self.in? Page.visible_to(user, options)
  end

end