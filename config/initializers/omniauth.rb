Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.application.secrets.omniauth_github_app_id
    provider :github,
      Rails.application.secrets.omniauth_github_app_id,
      Rails.application.secrets.omniauth_github_app_secret,
      scope: 'user:email' # https://developer.github.com/v3/oauth/#scopes
  end
  if Rails.application.secrets.omniauth_twitter_app_id
    provider :twitter,
      Rails.application.secrets.omniauth_twitter_app_id,
      Rails.application.secrets.omniauth_twitter_app_secret
  end

end