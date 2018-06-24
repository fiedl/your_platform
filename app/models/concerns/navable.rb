# A navable object has a menu, breadcrumbs etc.
# Special settings (like hiding a navable from the menu) are determined by the `nav_node`.
#
concern :Navable do
  included do

    include NavableBreadcrumbs
    include NavableVerticalNavs

    has_one :nav_node, as: :navable, dependent: :destroy, autosave: true

    accepts_nested_attributes_for :nav_node
    attr_accessible :nav_node_attributes if defined? attr_accessible

    delegate :hidden_menu, :hidden_menu=,
      :slim_menu, :slim_menu=,
      :slim_breadcrumb, :slim_breadcrumb=,
      :show_in_menu, :show_in_menu?, :show_in_menu=,
      :show_as_teaser_box, :show_as_teaser_box?, :show_as_teaser_box=,
      to: :nav_node
    attr_accessible :hidden_menu, :slim_menu, :slim_breadcrumb,
      :show_as_teaser_box, :show_in_menu if defined? attr_accessible

    after_save { nav_node.save }

    def is_navable?
      true
    end

    def navable?
      is_navable?
    end

    def nav_node
      @nav_node ||= (super || build_nav_node)
    end

    def navnode
      nav_node
    end

    def nav
      nav_node
    end

    def home_page
      nav_node.breadcrumb_root if nav_node.breadcrumb_root.kind_of? Pages::HomePage
    end

    def in_intranet?
      ([self] + self.ancestor_navables).include? Page.find_intranet_root
    end

    unless defined? layout
      def layout
        home_page.try(:layout)
      end
    end

    def show_vertical_nav?
      # `Page` overrides this method.
      (self.children.count + self.ancestors.count > 1)
    end

    # We do not show all kinds of objects in the menu.
    # Therefore select the appropriate items.
    #
    def navable_children
      (respond_to?(:child_groups) ? child_groups : []) +
      (respond_to?(:child_pages) ? child_pages.where.not(id: nil) : [])
    end

    def build_nav_node(*args)
      n = super(*args)
      n.navable = self
      return n
    end

    include NavableCaching if use_caching?

  end
end
