class MyGroupsController < ApplicationController
  def index
    authorize! :index, :my_groups
    set_current_navable current_user
    set_current_title t :my_groups
  end
end
