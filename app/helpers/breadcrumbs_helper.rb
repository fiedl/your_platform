module BreadcrumbsHelper

  # This returns an array of the currently shown breadcrumbs.
  #
  # The breadcrumbs can either be of type `NavNode` or of `Hash`.
  # The latter is set through `set_current_breadcrumbs` in the controller.
  #
  def current_breadcrumbs
    manual_current_breadcrumbs || current_navable.try(:breadcrumbs) || breadcrumbs_for_title(current_title)
  end

  def breadcrumbs_for_title(title)
    [
      {path: page_path(Page.root), title: Page.root.title},
      {path: page_path(Page.intranet_root), title: Page.intranet_root.title}
    ] + (manual_current_breadcrumbs || [{title: title}])
  end

end
