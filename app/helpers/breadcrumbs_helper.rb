module BreadcrumbsHelper

  # This returns an array of the currently shown breadcrumbs.
  #
  # The breadcrumbs can either be of type `NavNode` or of `Hash`.
  # The latter is set through `set_current_breadcrumbs` in the controller.
  #
  def current_breadcrumbs
    manual_current_breadcrumbs || (navable_breadcrumbs + (show_resource_nav? ? resource_breadcrumbs : []))
  end

  def navable_breadcrumbs
    current_navable.try(:breadcrumbs) || if Page.root
      [Page.root.nav_node, Page.intranet_root.nav_node]
    else
      []
    end
  end

  def resource_breadcrumbs
    ancestor_resource_controllers.reverse.collect { |controller|
      if controller
        if controller.action_methods.include? 'index'
          underscored_controller_name = controller.name.gsub("Controller", "").underscore
          title = translate(underscored_controller_name)
          group_id = group.id if defined?(group) && group
          {title: title, path: url_for(controller: underscored_controller_name, action: "index", group_id: group_id, id: nil)}
        end
      end
    } - [nil] + [{title: current_title}]
  end

end
