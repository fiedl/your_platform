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
    scope :public_website, -> { where(id: Page.unscoped.public_website_page_ids) }

    scope :home_pages, -> { where.not(domain: nil) }

    scope :public_websites, -> { where(id: Page.unscoped.public_websites_page_ids) }

    scope :intranet, -> { where(id: (Page.flagged(:intranet_root).pluck(:id) + (Page.flagged(:intranet_root).first.try(:descendant_page_ids) || []))) }

  end

  def public?
    part_of_the_global_public_website? or part_of_a_local_public_website?
  end

  def part_of_the_global_public_website?
    self.id.in? self.class.public_website_page_ids
  end

  def part_of_a_local_public_website?
    (self.nav_node.breadcrumb_root.try(:type) == 'Pages::HomePage') and not part_of_the_intranet?
  end

  def part_of_the_intranet?
    (self.id == Page.intranet_root.id) or (self.ancestor_pages.include?(Page.intranet_root))
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
      (Page.flagged(:root).pluck(:id) + (Page.flagged(:root).try(:collect) { |root_page| root_page.descendant_page_ids }) || []).flatten - [nil] - Page.intranet.pluck(:id)
    end

    # There might be several websites.
    #
    def public_websites_page_ids
      public_website_page_ids + (Page.home_pages.pluck(:id) + Page.home_pages.collect { |home_page| home_page.descendant_page_ids }).flatten - [nil] - Page.intranet.pluck(:id)
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