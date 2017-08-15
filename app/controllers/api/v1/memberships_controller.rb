class Api::V1::MembershipsController < ApplicationController

  expose :object, -> { GlobalID::Locator.locate params[:object_gid] if params[:object_gid] }

  def index
    authorize! :read, object

    render json: object.memberships.with_past.as_json(methods: [:valid_from_localized_date, :valid_to_localized_date])
  end

end