class Page < ApplicationRecord

  has_dag_links ancestor_class_names: %w(Page User Group Event), descendant_class_names: %w(Page User Group Event), link_class_name: 'DagLink'
  #after_save { parent.try(:touch) }  # This causes some specs to fail. TODO: Check if this is a spec issue or has destructive implications.

  acts_as_taggable

  has_many :attachments, as: :parent, dependent: :destroy

  serialize :redirect_to
  serialize :box_configuration

  include Structureable
  include PageGraph
  include Navable
  include HasAuthor
  include PagePublicWebsite
  include Archivable
  include PageHasSettings
  include HasPermalinks
  include RelatedPages
  include PageEvents
  include PageOfficers
  include PageTeaserBoxes
  include PagePublishing
  include PageVisibility
  include PageEmbedding
  include PageImages
  include PageSearch
  include PageFooter

  scope :regular, -> {
    where(type: nil)
  }

  def not_empty?
    attachments.any? || (content && content.length > 5) || children.any?
  end


  # This is the page title. If the title is not given in the
  # database, try to translate the flag of the page, e.g.
  # for the 'imprint' page.
  #
  def title
    if defined?(super) && super.present?
      super
    else
      I18n.translate(self.flags.first, default: '')
    end
  end
  def to_s
    title
  end

  def as_json(options = {})
    super.as_json(options).merge({tag_list: tag_list})
  end

  def show_vertical_nav?
    (self.type != 'Pages::HomePage') && ((self.navable_children.select(&:show_in_menu?).count > 0) || self.parents.first.try(:show_vertical_nav?))
  end

  def group_map_parent_group_id
    settings.group_map_parent_group_id || Group.corporations_parent.id
  end

  # This is the group the page belongs to, for example:
  #
  #     group_1
  #       |----- group_2
  #       |        |------ page_2 : belongs to group_2
  #       |
  #       |--------------- page_1 : belongs to group_1
  #
  def group
    Group.find group_id if group_id
  end
  def group_id
    # Do not use `ancestor_groups.last` here. Where this would work somethimes, it depends on the
    # order of creation of the links.
    next_parent = parent_groups.first || parent_pages.first
    until next_parent.nil? or next_parent.kind_of? Group
      next_parent = next_parent.parent_groups.first || next_parent.parent_pages.first
    end
    next_parent.try(:id)
  end

  # A sub_page is a descendant_page of the page
  # that is of the same group, i.e. not a page of
  # one of the sub groups.
  #
  def sub_page_ids
    (child_page_ids + child_pages.map(&:child_page_ids)).flatten
  end
  def sub_pages
    Page.regular.where(id: sub_page_ids)
  end

  # Url
  # ----------------------------------------------------------------------------------------------------

  # This sets the format of the Page urls to be
  #
  #     example.com/pages/24-products
  #
  # rather than just
  #
  #     example.com/pages/24
  #
  def to_param
    "#{id} #{title}".parameterize
  end


  # Quick Assignment of Children
  # ----------------------------------------------------------------------------------------------------

  # Add a child to this page. This could be a blog entry or another page or even a group.
  # Example:
  #
  #     my_page << another_page
  #
  def <<(child)
    unless child.in? self.children
      if child.in? self.descendants
        link = DagLink.where(
          ancestor_type: 'Page', ancestor_id: self.id,
          descendant_type: child.class.name, descendant_id: child.id
        ).first
        link.make_direct
        link.save
      else
        self.child_pages << child if child.kind_of? Page
        self.child_groups << child if child.kind_of? Group
      end
    end
  end


  # Redirection
  # ----------------------------------------------------------------------------------------------------

  # The `redirect_to` attribute can have the following forms:
  #
  #   * "http://example.com"
  #   * {controller: 'users', action: 'index'}
  #   * "users#index"  as short form of the previous one.
  #
  def redirect_to
    if super.kind_of?(String) && super.include?("#")
      controller, action = super.split("#")
      { controller: controller, action: action } if controller && action
    else
      super
    end
  end

  # Association Related Methods
  # ----------------------------------------------------------------------------------------------------

  # This return alls attachments of a certain type.
  # +type+ could be something like `image` or `pdf`. It will be compared to the attachments' mime type.
  #
  def attachments_by_type( type )
    attachments.find_by_type type
  end


  # Blog Entries
  # ----------------------------------------------------------------------------------------------------

  # This method returns all Page objects that can be regarded as blog entries of self.
  # They won't show up in the vertical menu.
  #
  # Page: "My Blog"
  #   |------------------ BlogPost: "Entry 1"
  #   |------------------ BlogPost: "Entry 2"
  #
  def blog_entries
    blog_posts
  end
  def blog_posts
    child_pages.where(type: "BlogPost").order_by_published_at
  end
  def child_blog_posts
    child_pages.where(type: "BlogPost").order_by_published_at
  end
  def descendant_blog_posts
    descendant_pages.where(type: "BlogPost").order_by_published_at
  end
  def self.order_by_published_at
    # The minus makes unpublished top.
    # https://stackoverflow.com/a/14595507/2066546
    # TODO: Change this when migrating to postgres.
    self.order("-published_at ASC")
  end

  # Finder and Creator Methods
  # ----------------------------------------------------------------------------------------------------


  # root

  def self.root
    Page.find_root
  end

  def self.find_root
    Page.unscoped.find_by_flag(:root)
  end

  def self.find_or_create_root
    self.find_root || self.create_root
  end

  def self.create_root(attrs = {})
    root_page = Page.create(title: "Root", published_at: Time.zone.now, domain: "example.com")
    root_page.update_attributes attrs
    root_page.add_flag :root
    n = root_page.nav_node; n.slim_menu = true; n.save; n = nil
    return root_page
  end


  # intranet root

  def self.intranet_root
    self.find_intranet_root
  end

  def self.find_intranet_root
    Page.find_by_flag( :intranet_root )
  end

  def self.find_or_create_intranet_root
    self.find_intranet_root || self.create_intranet_root
  end

  def self.create_intranet_root(attrs = {})
    root_page = Page.find_by_flag :root
    root_page = self.create_root unless root_page
    intranet_root = root_page.child_pages.create(title: "Intranet", published_at: Time.zone.now)
    intranet_root.update_attributes attrs
    intranet_root.add_flag :intranet_root
    return intranet_root
  end

  def self.intranet_root
    self.find_or_create_intranet_root
  end


  # help page

  def self.find_help_page
    Page.find_by_flag( :help )
  end

  def self.find_or_create_help_page
    self.find_help_page || self.create_help_page
  end

  def self.create_help_page
    help_page = Page.create published_at: Time.zone.now
    help_page.add_flag :help
    n = help_page.nav_node; n.hidden_menu = true; n.save;
    return help_page
  end

  # imprint

  def self.create_imprint
    imprint_page = Page.create published_at: Time.zone.now
    imprint_page.add_flag :imprint
    return imprint_page
  end
  def self.find_imprint
    Page.find_by_flag :imprint
  end

  # All descendant pages where no other object type is inbetween.
  #
  def connected_descendant_pages
    Page.find connected_descendant_page_ids
  end
  def connected_descendant_page_ids
    # The step between root and intranet root needs to be
    # excluded here, since this is no ordinary step between
    # pages.
    # See: `#administrated_objects`.
    (self.child_pages - [Page.find_intranet_root]).collect do |child_page|
      [child_page] + child_page.connected_descendant_pages
    end.flatten.uniq.map(&:id)
  end

  def self.types
    [nil, Page, BlogPost, Blog, Pages::HomePage, Pages::ContactForm, Pages::NextEventPage, Pages::EventsPage]
  end

  include PageCaching if use_caching?
end
