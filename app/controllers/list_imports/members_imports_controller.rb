class ListImports::MembersImportsController < ApplicationController

  expose :group

  def new
    authorize! :import_members, group

    set_current_title t(:import_str, str: group.name)
    set_current_navable group
  end

end