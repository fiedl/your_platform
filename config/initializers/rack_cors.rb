Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'

    # The `expose` is needed for angular-token:
    # https://github.com/neroniaky/angular-token/wiki/Common-Problems
    #
    resource '/api/*', headers: :any, methods: [:get, :post, :options], expose: ['access-token', 'expiry', 'token-type', 'uid', 'client']
  end
end
