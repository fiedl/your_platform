class GroupPagesController < ApplicationController

  expose :group

  def index
    authorize! :read_pages, group

    set_current_navable group
    set_current_title group.title
    set_current_tab :pages
  end

end