# A navable object has a menu, breadcrumbs etc.
# Special settings (like hiding a navable from the menu) are determined by the `nav_node`.
#
concern :Navable do
  included do

    has_one :nav_node, as: :navable, dependent: :destroy, autosave: true

    accepts_nested_attributes_for :nav_node
    attr_accessible :nav_node_attributes

    #delegate :show_in_menu, :show_in_menu=, to: :nav_node
    #attr_accessible :show_in_menu

    delegate :hidden_menu, :hidden_menu=,
      :slim_menu, :slim_menu=,
      :slim_breadcrumb, :slim_breadcrumb=,
      to: :nav_node
    attr_accessible :hidden_menu, :slim_menu, :slim_breadcrumb

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

  end
end
