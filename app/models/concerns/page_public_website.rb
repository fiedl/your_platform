# This handles the Page-specific functionality concerning the
# public website features of YourPlatform.
#
concern :PagePublicWebsite do
  included do

    # Page.find_root (:root)          <
    #      |------ public_page_1      < public website
    #      |------ public_page_2      <
    #      |
    #      |------ Page.find_intranet_root (:intranet_root)
    #
    scope :public_website, -> { where(id: public_website_page_ids) }

  end

  def public?
    self.id.in? self.class.public_website_page_ids
  end

  class_methods do

    def public_website_page_ids(reload = false)
      @public_website_page_ids = nil if reload
      @public_website_page_ids ||= (Page.flagged(:root).pluck(:id) + (Page.flagged(:root).try(:collect) { |root_page| root_page.descendant_page_ids }) || []).flatten - [nil] - Page.flagged(:intranet_root).pluck(:id) - (Page.flagged(:intranet_root).first.try(:descendant_page_ids) || [])
    end

    # The public website is present if the Page.find_root has no redirect_to entry,
    # i.e. just redirects to an external website.
    #
    def public_website_present?
      not Page.find_root.redirect_to.present?
    end

    def public_root
      Page.find_root
    end

  end
end