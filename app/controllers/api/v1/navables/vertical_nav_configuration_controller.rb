class Api::V1::Navables::VerticalNavConfigurationController < ApplicationController

  expose :navable, -> { GlobalID::Locator.locate params[:navable_gid] if params[:navable_gid] }

  def update
    authorize! :manage, navable

    navable.nav_configuration = params[:nav_configuration]
    render json: {}, status: :ok
  end

end