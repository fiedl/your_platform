class Officers::ByFlagController < ApplicationController

  expose :flag, -> { params[:flag] }
  expose :officer_groups, -> { OfficerGroup.flagged(flag) }

  def index
    authorize! :index, :officers

    set_current_title t(flag)
  end

end