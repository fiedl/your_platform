class Api::V1::CurrentRoleController < ApplicationController

  expose :object, -> { GlobalID::Locator.locate params[:object_gid] if params[:object_gid] }

  api :GET, '/api/v1/current_role', "Returns the role of the current user for the given object."
  param :object_gid, String, "Global id of the object"

  skip_authorization_check only: [:show]

  def show
    render json: if current_user
      Role.of(current_user).for(object).as_json
    else
      {}
    end
  end

end