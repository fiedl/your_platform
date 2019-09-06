class HorizontalNav
  def initialize(args)
    @user = args[:user]
    @current_navable = args[:current_navable]
    @current_home_page = args[:current_home_page]
  end

  def self.for_user(user, args = {})
    self.new(args.merge({ user: user }))
  end

  def link_objects
    objects = navables.to_a
    objects << {title: I18n.t(:horizontal_nav_sign_in), path: '/sign_in'} if not logged_in?
    objects
  end

  def navables
    if logged_in?
      intranet_navables
    else
      public_navables.select { |navable| not navable.nav_node.hidden_menu? }
    end
  end

  def intranet_navables
    [ Page.find_intranet_root ] + (@user.try(:current_corporations) || [])
  end

  def public_navables
    if current_home_page
      pages = [current_home_page]
      if current_home_page.respond_to? :horizontal_nav_child_pages
        pages += current_home_page.horizontal_nav_child_pages
      else
        pages += current_home_page.child_pages.where(type: [nil, 'Page', 'Blog'])
      end

      # Sort by the persisted order.
      # http://stackoverflow.com/a/7790994/2066546
      if current_home_page.respond_to?(:settings) && current_home_page.settings.horizontal_nav_page_id_order.kind_of?(Array)
        pages_by_id = Hash[pages.map { |p| [p.id, p] }]
        pages = (pages_by_id.values_at(*current_home_page.settings.horizontal_nav_page_id_order) + pages).uniq
      end

      # Filter "new page" element (id: nil) and hidden pages.
      pages = pages.select { |page| page.try(:id) && page.show_in_menu? }

      return pages
    else
      return []
    end
  end

  def currently_in_intranet?
    current_navable.try(:in_intranet?)
  end

  def current_navable
    @current_navable
  end

  def current_home_page
    @current_home_page || Page.root
  end

  def breadcrumb_root
    @breadcrumb_root ||= current_navable.try(:nav_node).try(:breadcrumb_root).try(:reload)
  end

  def logged_in?
    return true if @user
  end
end
