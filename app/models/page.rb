class Page < ActiveRecord::Base

  attr_accessible        :content, :title, :redirect_to, :author, :author_user_id, :box_configuration, :type if defined? attr_accessible

  is_structureable       ancestor_class_names: %w(Page User Group Event), descendant_class_names: %w(Page User Group Event)
  is_navable

  has_many :attachments, as: :parent, dependent: :destroy

  belongs_to :author, :class_name => "User", foreign_key: 'author_user_id'

  serialize :redirect_to
  serialize :box_configuration

  include PagePublicWebsite
  include Archivable

  scope :for_display, -> { not_archived.includes(:ancestor_users,
    :ancestor_events, :author, :parent_pages,
    :parent_users, :parent_groups, :parent_events) }

  # Easy settings: https://github.com/huacnlee/rails-settings-cached
  # For example:
  #
  #     page = Page.find(123)
  #     page.settings.color = :red
  #     page.settings.color  # =>  :red
  #
  include RailsSettings::Extend


  def not_empty?
    attachments.count > 0 or (content && content.length > 5)
  end

  def fill_cache
    group
  end


  # This is the page title. If the title is not given in the
  # database, try to translate the flag of the page, e.g.
  # for the 'imprint' page.
  #
  def title
    super.present? ? super : I18n.translate(self.flags.first, default: '')
  end
  def to_s
    title
  end

  def child_teaser_boxes
    teaser_boxes
  end
  def teaser_boxes
    # # For some reason, this does not work: FIXME
    # child_pages
    #   .where.not(type: 'BlogPost')
    #   .where.not(nav_nodes: {hidden_teaser_box: true})
    #
    child_pages
      .select { |page| not page.type == 'BlogPost'}
      .select { |page| not page.nav_node.hidden_teaser_box }
  end
  def teaser_text
    if content
      teaser_content = content.split("\n\n").first
      teaser_content += "\n\n" + content.split("\n\n").second if teaser_content.start_with?("http") # For inline videos etc.
      teaser_content
    end
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
    # Do not use `ancestor_groups.last` here. Where this would work somethimes, it depends on the
    # order of creation of the links.
    cached do
      next_parent = parent_groups.first || parent_pages.first
      until next_parent.nil? or next_parent.kind_of? Group
        next_parent = next_parent.parent_groups.first || next_parent.parent_pages.first
      end
      next_parent
    end
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
  def image_attachments
    attachments_by_type 'image'
  end


  # Blog Entries
  # ----------------------------------------------------------------------------------------------------

  # This method returns all Page objects that can be regarded as blog entries of self.
  # Blog entries are simply child pages of self that have the :blog_entry flag.
  # They won't show up in the vertical menu.
  #
  # Page: "My Blog"
  #   |------------------ Page: "Entry 1"
  #   |------------------ Page: "Entry 2"
  #
  def blog_entries
    self.child_pages.where(type: "BlogPost").order('created_at DESC')
  end


  # Finder and Creator Methods
  # ----------------------------------------------------------------------------------------------------


  # root

  def self.root
    self.find_root
  end

  def self.find_root
    Page.find_by_flag( :root )
  end

  def self.find_or_create_root
    self.find_root || self.create_root
  end

  def self.create_root(attrs = {})
    root_page = Page.create(title: "Root")
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
    intranet_root = root_page.child_pages.create(title: "Intranet")
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
    help_page = Page.create
    help_page.add_flag :help
    n = help_page.nav_node; n.hidden_menu = true; n.save;
    return help_page
  end

  # imprint

  def self.create_imprint
    imprint_page = Page.create
    imprint_page.add_flag :imprint
    return imprint_page
  end
  def self.find_imprint
    Page.find_by_flag :imprint
  end

end
