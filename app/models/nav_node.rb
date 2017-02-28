# -*- coding: utf-8 -*-
#
# Each Navable object has got an associated NavNode, i.e. an object representing the information
# relevant to the position of the Navable object within the navigational structure.
#
class NavNode < ActiveRecord::Base
  if defined? attr_accessible
    attr_accessible :breadcrumb_item, :hidden_menu, :menu_item, :slim_breadcrumb, :slim_menu, :slim_url, :url_component
    attr_accessible :hidden_footer
  end

  belongs_to :navable, polymorphic: true

  include RailsSettings::Extend
  delegate :hidden_footer, :hidden_footer=, to: :settings


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
  def breadcrumb_title
    breadcrumb_item
  end

  # The +menu_item+ is the string representing the Navable in the vertical menu.
  # It defaults to the Navable's title and can be customized using the setter method
  # +menu_item=+.
  #
  def menu_item
    super || self.navable.title
  end
  def nav_title
    menu_item
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

  # The breadcrumb_root is the navable that is the left-most of the breadcrums
  # of the navable.
  #
  #    example.com > About us
  #    ~~~~~~~~~~~
  #
  def breadcrumb_root
    ancestor_nodes_and_self.first.navable
  end

  # +ancestor_nodes+ returns an Array of the NavNodes of the ancestors of the Navable
  # associated with this NavNode.
  #
  def ancestor_nodes
    if parent
      parent.ancestor_nodes + [parent]
    else
      []
    end
  end

  # +ancestor_nodes_and_self+ returns an Array of the NavNodes of the ancestors of the
  # Navable associated with this NavNode  plus  this NavNode as last element.
  #
  def ancestor_nodes_and_self
    ancestor_nodes + [self]
  end

  def parent
    navable.parent.try(:nav_node)
  end

end

