class Api::V1::BaseController < ApplicationController

  skip_before_action :verify_authenticity_token
  protect_from_forgery with: :null_session, only: -> { request.format.json? }
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_api_v1_user_account_if_needed

  # During the API test phase, we log the API requests, except for passwords.
  # `log_request` is defined in the `ApplicationController`.
  # The requests can be viewed at `/requests`.
  after_action :log_request

  # The API can be used either by our mobile apps, using token authentication,
  # or by our web app, using default session cookies.
  #
  def authenticate_api_v1_user_account_if_needed
    authenticate_api_v1_user_account! if request.headers["HTTP_ACCESS_TOKEN"].present?
  end

end