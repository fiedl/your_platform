module RolePreviewHelper
  def show_role_preview_menu?
    @show_role_preview_menu ||= (current_role && ((current_navable && current_role.officer?) or current_role.global_officer?))
  end
end