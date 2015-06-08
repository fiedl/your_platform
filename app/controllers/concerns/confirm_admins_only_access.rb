concern :ConfirmAdminsOnlyAccess do
  
  included do
    # A `before_action` callback such as
    #
    #     before_action :confirm_admins_only_access_if_needed
    #
    # is too early. `current_navable` is not available then.
    # Therefore, hook this in the `set_current_navable` setter.

    helper_method :can_override_access_denied?
    helper_method :current_navable_or_navable_for_admins_only_confirmation
    
    before_action { session[:admins_only_override] ||= params[:admins_only_override] }
  end
  
  # Some users, mainly global admins, have access to information
  # they would not have access to as regular users, in order to be
  # able to help other users.
  #
  # But, we don't want admins to abuse this access. Therefore,
  # ask them to confirm that they want to access a certain resource
  # and tell them that the access will be logged.
  #
  def confirm_admins_only_access_if_needed
    if request.get? and request.format.html?
      if current_navable and can?(:read, current_navable) and not current_ability_as_user.can?(:read, current_navable)
        confirm_admins_only_access
      end
    end
  end
  
  def confirm_admins_only_access
    if session[:admins_only_override]
      PublicActivity::Activity.create!(
        trackable: current_navable_or_navable_for_admins_only_confirmation,
        key: "read admins_only_override",
        owner: current_user
      )

      session[:admins_only_override] = nil
      session[:confirm_admins_only_access_for_navable_global_id] = nil
    else
      session[:confirm_admins_only_access_for_navable_global_id] = current_navable.to_global_id.to_s
      raise CanCan::AccessDenied
    end
  end
  
  def can_override_access_denied?
    current_navable_or_navable_for_admins_only_confirmation and can?(:read, current_navable_or_navable_for_admins_only_confirmation)
  end
  
  def current_navable_or_navable_for_admins_only_confirmation
    current_navable || GlobalID::Locator.locate(session[:confirm_admins_only_access_for_navable_global_id])
  end
  
end