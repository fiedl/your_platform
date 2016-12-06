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
    objects << {title: I18n.t(:sign_in), path: '/sign_in'} if not logged_in?
    objects
  end

  def navables
    if currently_in_intranet?
      intranet_navables
    else
      public_navables
    end.select { |navable| not navable.nav_node.hidden_menu?}
  end

  def intranet_navables
    [ Page.find_intranet_root ] + (@user.try(:current_corporations) || [])
  end

  def public_navables
    navables = [current_home_page]
    navables += current_home_page.child_pages.where(type: [nil, 'Page', 'Blog'])
    navables -= [Page.find_intranet_root, Page.find_imprint]
    navables -= Page.flagged(:public_root_element)
    return navables
  end

  def currently_in_intranet?
    current_navable && ([current_navable] + current_navable.ancestor_pages).include?(Page.find_intranet_root)
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
