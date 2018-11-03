class Api::V1::BaseController < ApplicationController

  skip_before_action :verify_authenticity_token
  protect_from_forgery with: :null_session, only: -> { request.format.json? }
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_api_v1_user_account!

end