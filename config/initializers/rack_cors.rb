Rails.application.config.middleware.insert_before 0, Rack::Cors do

  # Allow access through our mobile app via the api.
  #
  allow do
    origins '*'

    # The `expose` is needed for angular-token:
    # https://github.com/neroniaky/angular-token/wiki/Common-Problems
    #
    resource '/api/*', headers: :any, methods: [:get, :post, :put, :options], expose: ['access-token', 'expiry', 'token-type', 'uid', 'client']
  end

  # Allow sign-in from external forms.
  # The domains of the websites the exteral sign-in forms are on
  # need to go into this environment variable:
  #
  #     EXTERNAL_SIGN_IN_FORM_DOMAINS="example.com,example.org"
  #
  if ENV['EXTERNAL_SIGN_IN_FORM_DOMAINS']
    allow do
      origins ENV['EXTERNAL_SIGN_IN_FORM_DOMAINS'].split(",")

      resource '*'
    end
  end
end
