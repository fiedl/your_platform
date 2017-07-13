class Page < ActiveRecord::Base

  is_structureable       ancestor_class_names: %w(Page User Group Event), descendant_class_names: %w(Page User Group Event)

  acts_as_taggable

  has_many :attachments, as: :parent, dependent: :destroy


  serialize :redirect_to
  serialize :box_configuration

  include Navable
  include HasAuthor
  include PagePublicWebsite
  include Archivable
  include PageHasSettings
  include HasPermalinks
  include RelatedPages

  scope :for_display, -> { not_archived.includes(:ancestor_users,
    :ancestor_events, :author, :parent_pages,
    :parent_users, :parent_groups, :parent_events) }

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

  def content_boxes
    child_pages.where(type: "Pages::ContentBox")
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
      .select { |page| not page.type.in? ['BlogPost', 'Pages::ContentBox'] }
      .select { |page| not page.nav_node.hidden_teaser_box }
      .select { |page| not page.new_record? }
  end
  def teaser_text
    super || if content
      paragraphs = content
        .gsub(teaser_youtube_url.to_s, '')
        .gsub(/\n[ ]*\n/, "\n\n").split("\n\n")
      teaser_content = paragraphs.first
      teaser_content += "\n\n" + paragraphs.second if teaser_content.start_with?("http") # For inline videos etc.
      teaser_content
    end
  end
  def teaser_image_url
    if self.settings.teaser_image_url
      self.settings.teaser_image_url
    else
      possible_teaser_image_urls.first
    end
  end
  def teaser_image_url=(new_url)
    if new_url.present?
      self.settings.teaser_image_url = new_url
    else
      self.settings.teaser_image_url = nil
    end
  end
  def possible_teaser_image_urls
    image_attachments.map(&:medium_url) + if content.present?
      URI.extract(content)
        .select{ |l| l[/\.(?:gif|png|jpe?g)\b/]}
        .collect { |url| url.gsub(")", "") } # to fix markdown image urls
    else
      []
    end
  end
  def teaser_youtube_url
    content.to_s.match(/^(https?\:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/.+$/).try(:[], 0)
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
  def image_attachments
    attachments.find_by_type('image')
  end
  def image_attachments_not_listed_in_content
    image_attachments.select do |attachment|
      # Do not list images that are `![markdown-images](...)` within the
      # page content as attachments in order to avoid displaying them
      # twice.
      not self.content.try(:include?, attachment.file_path)
    end
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
    child_pages.where(type: "BlogPost").order('created_at DESC')
  end
  def child_blog_posts
    child_pages.where(type: "BlogPost").order('created_at DESC')
  end
  def descendant_blog_posts
    descendant_pages.where(type: "BlogPost").order('created_at DESC')
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
    [nil, Page, BlogPost, Blog, Pages::HomePage, Pages::ContentBox]
  end

  include PageCaching if use_caching?
end
