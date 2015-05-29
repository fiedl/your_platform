concern :CurrentRole do
  
  included do
    helper_method :current_role
    helper_method :current_role_view
    helper_method :current_role_preview
  end
  
  # The current_role returns always the *real* role not the preview role.
  # For the preview role, use `current_role_view`.
  #
  def current_role
    @current_role ||= ::Role.of(current_user).for(current_navable || Group.everyone) if current_user
  end
  
  # The current role the user really has can differ from the role preview
  # he wants to see. While `current_role` returns the real role, this method
  # returns the one that is to be displayed.
  #
  def current_role_view
    @current_role_view ||= current_role_preview || current_role.to_s
  end
  
  def current_role_preview
    preview_as = nil
    if current_user
      preview_as = params[:preview_as] || load_preview_as_from_cookie
      if preview_as.present? || current_user.is_global_officer?
        if preview_as.in?(current_role.allowed_preview_roles)
          save_preview_as_cookie(preview_as)
        else
          cookies.delete :preview_as
          preview_as = nil
        end
      end
    end
    return preview_as
  end

  private
  
  def load_preview_as_from_cookie
    cookies[:preview_as]
  end
  def save_preview_as_cookie(preview_as)
    cookies[:preview_as] = preview_as
  end
  
end