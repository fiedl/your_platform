class GroupNewsController < ApplicationController

  expose :group

  def index
    authorize! :read_news, group

    set_current_navable group
    set_current_title "News - #{group.name}"
    set_current_tab :news
  end

end