class Api::V1::BaseController < ApplicationController

  skip_before_action :verify_authenticity_token
  protect_from_forgery with: :null_session, only: -> { request.format.json? }
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :authenticate_api_v1_user_account!

  # During the API test phase, we log the API requests, except for passwords.
  # `log_request` is defined in the `ApplicationController`.
  # The requests can be viewed at `/requests`.
  after_action :log_request

end