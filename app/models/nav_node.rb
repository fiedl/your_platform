# Each Navable object has got an associated NavNode, i.e. an object representing the information
# relevant to the position of the Navable object within the navigational structure.
#
class NavNode < ActiveRecord::Base
  if defined? attr_accessible
    attr_accessible :breadcrumb_item, :slim_breadcrumb
    attr_accessible :hidden_menu, :menu_item, :slim_menu
    attr_accessible :slim_url, :url_component
    attr_accessible :hidden_teaser_box
    attr_accessible :hidden_footer
  end

  belongs_to :navable, polymorphic: true

  include RailsSettings::Extend
  delegate :hidden_footer, :hidden_footer=, to: :settings

  after_save :delete_cache

  def delete_cache
    super
    Rails.cache.delete_matched '*horizontal_nav*' if @hidden_menu_has_changed
  end


  # Show the navable object in the page footer?
  def show_in_footer?
    return false if hidden_footer
    return true if hidden_footer == false
    return false if navable.kind_of?(Page) && navable.attachments.logos.any?
    return true
  end

  # The +url_component+ represents the part of the url, which is contributed by
  # the Navable object.
  #
  # If you have the following url
  #   http://example.com/products/phones/ ,
  # and the current Navable is the Page @products_page, then its +url_component+ is
  # 'products/'.
  #
  #     @products_page = Page.find_by_title("Products")
  #     @products_page.nav_node.url_component  # => "products/"
  #
  # The default +url_component+ uses the Navable's title.
  # But you can override the url_component of a Navable just by setting it.
  #
  #     @nav_node = @products_page.nav_node
  #     @nav_node.url_component = "our_products/"
  #     @nav_node.save
  #
  def url_component
    super || "#{self.navable.title.parameterize}/"
  end

  # The +breadcrumb_item+ is the string representing the Navable in a breadcrumb navigation.
  #
  # For example:   example.com  >  Products  >  Phones
  #                                --------
  # The String "Products" is the +breadcrumb_item+ of the @products_page.
  # It defaults to the Navable's title and can be customized using the setter method
  # +breadcrumb_item=+.
  #
  def breadcrumb_item
    super || self.navable.title
  end

  # The +menu_item+ is the string representing the Navable in the vertical menu.
  # It defaults to the Navable's title and can be customized using the setter method
  # +menu_item=+.
  #
  def menu_item
    super || self.navable.title
  end

  # The +hidden_menu+ attribute says if the Navable should be hidden from
  # the vertical menu.
  #
  # By default,
  #   * Pages are shown in the menu
  #   * Groups are shown in the menu
  #   *   exception: The :officers_parent groups are hidden in the menu.
  #   * Users are hidden in the menu
  #   * Events are hidden in the menu
  #   * Workflows are hidden in the menu
  #
  # You can override the setting for a Navable by using the setter method
  # +hidden_menu=+ on the NavNode.
  #
  def hidden_menu
    hidden = super
    hidden = true if self.navable.kind_of? User if hidden.nil?
    hidden = true if self.navable.kind_of? Event if hidden.nil?
    hidden = true if self.navable.title == I18n.t(:officers_parent) if hidden.nil?
    hidden = true if self.navable.kind_of?(Page) && (self.navable.type == "BlogPost")
    hidden = false if hidden.nil?
    return hidden
  end

  def hidden_menu=(new_value)
    @hidden_menu_has_changed = true
    super(new_value)
  end

  def show_in_menu?
    show_in_menu
  end
  def show_in_menu
    not hidden_menu
  end
  def show_in_menu=(new_value)
    self.hidden_menu = (not new_value)
  end

  def hidden_teaser_box
    super || false
  end

  def show_as_teaser_box?
    show_as_teaser_box
  end
  def show_as_teaser_box
    not hidden_teaser_box
  end
  def show_as_teaser_box=(new_value)
    self.hidden_teaser_box = (not new_value)
  end

  # +slim_breadcrumbs+ marks if the Navable should be hidden from the breadcrumb navigation
  # in order to save space.
  #
  # By default, no element is hidden from the breadcrumb navigation.
  # To hide an element, just set
  #
  #   @some_page.nav_node.update_attribute(:slim_breadcrumb, true)
  #
  def slim_breadcrumb
    super || false
  end

  # +url+ returns the joined url_components of this NavNode's Navable and its ancestors
  # resulting in the generated url of the Navable.
  #
  # Example:
  #   Breadcrumb:  Example.com  >  Products  >  Phones
  #   Url:         http://example.com/products/phones
  #
  # A possible trailing slash is removed from the +url+. Thus, the example's url does
  # end on 'phones' rather than 'phones/'.
  #
  def url
    url = ancestor_nodes_and_self.collect do |nav_node|
      nav_node.url_component
    end.join.gsub( /(\/)$/, '' ) # The gsub call removes the trailing slash.
  end

  # +breadcrumbs+ returns an Array of breadcrumb Hashes representing the route to the
  # Navable associated with this NavNode.
  #
  # Example:
  #   Breadcrumb:  Example.com  >  Products  >  Phones
  #   Url:         http://example.com/products/phones
  #
  #     @phones_page.nav_node.breadcrumbs
  #       # => [ {title: "Example.com", navable: @root_page, slim: false},
  #              {title: "Products", navable: @products_page, slim: false},
  #              {title: "Phones", navable: @phones_page, slim: false} ]
  #
  def breadcrumbs
    breadcrumbs_to_return = []
    navables = self.ancestor_navables_and_own
    for navable in navables do
      breadcrumbs_to_return << { title: navable.nav_node.breadcrumb_item,
                                 navable: navable,
                                 slim: navable.nav_node.slim_breadcrumb }
    end
    return breadcrumbs_to_return
  end

  # This returns the Navable ancestors of the Navable associated with this NavNode as an Array.
  #
  def ancestor_navables
    path = []
    current_navable = self.navable
    until current_navable.nil?
      new_navable = nil
      new_navable ||= current_navable.status_group_in_primary_corporation if current_navable.kind_of? User
      new_navable ||= current_navable.parents.select do |parent|
        parent.respond_to? :nav_node
      end.first
      path << new_navable if new_navable
      current_navable = new_navable
    end
    path.reverse
  end

  # This returns the Navable ancestors of the Navable associated with this NavNode as an Array
  # plus this NavNode's Navable as last element.
  #
  def ancestor_navables_and_own
    ancestor_navables + [ self.navable ]
  end

  # The breadcrumb_root is the navable that is the left-most of the breadcrums
  # of the navable.
  #
  #    example.com > About us
  #    ~~~~~~~~~~~
  #
  def breadcrumb_root
    cached { ancestor_navables_and_own.first }
  end

  # +ancestor_nodes+ returns an Array of the NavNodes of the ancestors of the Navable
  # associated with this NavNode.
  #
  def ancestor_nodes
    @ancestor_nodes ||= self.ancestor_navables.collect do |ancestor|
      ancestor.nav_node
    end
  end

  # +ancestor_nodes_and_self+ returns an Array of the NavNodes of the ancestors of the
  # Navable associated with this NavNode  plus  this NavNode as last element.
  #
  def ancestor_nodes_and_self
    ancestor_nodes + [ self ]
  end

  def cache_key
    [navable, "nav_node"]
  end

end

