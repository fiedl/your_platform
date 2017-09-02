class GroupPagesController < ApplicationController

  expose :group

  def index
    unless redirect_if_cannot_read_pages
      authorize! :read_pages, group

      set_current_navable group
      set_current_title group.title
      set_current_tab :pages
    end
  end

  private

  def redirect_if_cannot_read_pages
    if not can? :read_pages, group
      if not current_user.try(:global_admin?) # Because global admins could use override.
        authorize! :read, group
        redirect_to group_members_path(group_id: group.id)
        return true
      end
    end
    return false
  end

end