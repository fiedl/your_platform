class CorporationsController < ApplicationController

  expose :parent_group, -> { Group.corporations_parent }
  expose :corporations, -> { Corporation.active }

  def index
    authorize! :index, Corporation

    set_current_title "Verbindungen"
    set_current_navable parent_group
    set_current_tab :contacts
  end

end