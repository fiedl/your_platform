class PermalinksController < ApplicationController

  # https://railscasts.com/episodes/259-decent-exposure
  expose :page
  expose :reference, -> { page }

  def index
    authorize! :manage, reference

    set_current_navable reference
    set_current_title "#{reference.title}: #{t(:permalinks)}"
  end

end