# This controller handles authentication via
# https://github.com/lynndylanhurley/devise_token_auth
#
# How to test this controller:
#
#     be rails s -p 3001
#     curl http://localhost:3001/api/v1/auth/sign_in \
#         -i \
#         -X POST \
#         -H "Content-Type: application/json" \
#         -d '{"email": "foo@example.com", "password": "test"}'
#
#     curl -i http://localhost:3001/api/v1/current_user \
#         -X GET -H "Content-Type: application/json" \
#         -d '{"access-token": "0GYbI6K1QNhCO_BAtEILtw", "client": "tXwIPkEQutP9SJJ2O39B-g", "uid": "foo@example.com"}'
#
class Api::V1::SessionsController < DeviseTokenAuth::SessionsController

  api :POST, '/api/v1/auth/sign_in', "Signs in the user and returns an access token via the response header."
  param :login, String, "The alias, email or name of the user to sign in."
  param :password, String, "The password of the user to sign in."

  # https://github.com/lynndylanhurley/devise_token_auth/issues/398
  skip_before_action :verify_authenticity_token
  protect_from_forgery with: :null_session, only: -> { request.format.json? }

  def create
    login = params[:login] || params[:email] || params[:username]
    password = params[:password]

    account = UserAccount.identify(login)
    if account&.valid_password?(password)
      client_id, token = account.create_token
      account.uid = account.email; account.provider = "email"
      account.save

      sign_in :user_account, account, store: false, bypass: false

      # This is required to send the `access-token` within the
      # response headers. See: `set_user_by_token.rb`.
      #
      # See also: https://github.com/lynndylanhurley/devise_token_auth/issues/721
      # https://github.com/lynndylanhurley/devise_token_auth/issues/747
      #
      @resource = account; @client_id = client_id

      render json: {
        data: resource_data(resource_json: {
          login: login,
          account_id: account.id,
          user_id: account.user.id,
          email: account.email,
          account_errors: account.errors
        })
      }
    else
      render_create_error_bad_credentials
    end
  end

end