class Groups::GroupsOfGroupsController < ApplicationController

  expose :group

  def show
    authorize! :read, group

    set_current_navable group
    set_current_title group.title
    @hide_vertical_nav = true

    respond_to do |format|
      format.html
      format.csv do
        redirect_to groups_groups_of_groups_table_export_path(group, format: 'csv')
      end
      format.xls do
        redirect_to groups_groups_of_groups_table_export_path(group, format: 'xls')
      end
    end
  end

end
