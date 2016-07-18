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
    part_of_the_global_public_website? or part_of_a_local_public_website?
  end

  def part_of_the_global_public_website?
    self.id.in? self.class.public_website_page_ids
  end

  def part_of_a_local_public_website?
    self.nav_node.breadcrumb_root.try(:type) == 'Pages::HomePage'
  end

  def home_page
    nav_node.breadcrumb_root if nav_node.breadcrumb_root.kind_of? Pages::HomePage
  end

  def layout
    home_page.try(:layout)
  end

  class_methods do

    # The organization has a public website, example.com, and the intranet
    # as sub page. If the public website has sub pages that do not belong
    # to the intranet, i.e. which are public to each internet user, these
    # pages are considered as public_website_pages.
    #
    def public_website_page_ids(reload = false)
      @public_website_page_ids = nil if reload
      @public_website_page_ids ||= (Page.flagged(:root).pluck(:id) + (Page.flagged(:root).first.try(:descendant_page_ids) || []) - Page.flagged(:intranet_root).pluck(:id) - (Page.flagged(:intranet_root).first.try(:descendant_page_ids) || []))
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