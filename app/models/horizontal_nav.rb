class HorizontalNav
  def initialize(args)
    @user = args[:user]
    @current_navable = args[:current_navable]
  end

  def self.for_user(user, args = {})
    self.new(args.merge({ user: user }))
  end

  def link_objects
    objects = navables.to_a
    objects << { title: I18n.t(:sign_in), :controller => '/sessions', :action => :new } if not logged_in?
    objects
  end

  def navables
    if currently_in_intranet?
      intranet_navables
    else
      public_navables
    end.select { |navable| navable.show_in_menu? }
  end

  def intranet_navables
    [ Page.find_intranet_root ] + (@user.try(:current_corporations) || [])
  end

  def public_navables
    if breadcrumb_root
      [breadcrumb_root] + breadcrumb_root.horizontal_nav_child_pages
    else
      []
    end
    # [ Page.find_root ] + Page.find_root.child_pages.where(type: [nil, 'Page']) - [ Page.find_intranet_root, Page.find_imprint ] - Page.flagged(:public_root_element)
  end

  def currently_in_intranet?
    current_navable && ([current_navable] + current_navable.ancestor_pages).include?(Page.find_intranet_root)
  end

  def current_navable
    @current_navable
  end

  def breadcrumb_root
    @breadcrumb_root ||= current_navable.try(:nav_node).try(:breadcrumb_root)
  end

  def logged_in?
    return true if @user
  end
end
