concern :CurrentResource do
  included do
    helper_method :ancestor_resource_controllers
    helper_method :current_resource_category
  end

  class_methods do
    def set_parent_resource_controller(parent_resource_controller_class)
      @parent_resource_controller_class = parent_resource_controller_class
    end

    def parent_resource_controller
      @parent_resource_controller_class
    end

    def ancestor_resource_controllers
      [parent_resource_controller] + (parent_resource_controller.try(:ancestor_resource_controllers) || [])
    end
  end

  def ancestor_resource_controllers
    controllers = []
    controllers += [self.class] if action_name == "show"
    controllers += self.class.ancestor_resource_controllers
    controllers
  end

  def current_resource_category
    "members" if ancestor_resource_controllers.include? MembersDashboardController
  end
end