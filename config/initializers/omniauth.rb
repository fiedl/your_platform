#require 'omni_auth_provider'
#
#Rails.application.config.middleware.use OmniAuth::Builder do
#  if OmniAuthProvider.github.available?
#    provider :github,
#      OmniAuthProvider.github.app_id,
#      OmniAuthProvider.github.app_secret,
#      scope: 'user:email' # https://developer.github.com/v3/oauth/#scopes
#  end
#  if OmniAuthProvider.twitter.available?
#    provider :twitter,
#      OmniAuthProvider.twitter.app_id,
#      OmniAuthProvider.twitter.app_secret
#  end
#  if OmniAuthProvider.google.available?
#    provider :google_oauth2,
#      OmniAuthProvider.google.app_id,
#      OmniAuthProvider.google.app_secret,
#      verify_iss: false # https://stackoverflow.com/a/45292982/2066546
#  end
#  if OmniAuthProvider.facebook.available?
#    provider :facebook,
#      OmniAuthProvider.facebook.app_id,
#      OmniAuthProvider.facebook.app_secret,
#      scope: 'email'
#  end
#end

# dropped support for omniauth due to
# https://github.com/fiedl/your_platform/network/alert/demo_app/my_platform/Gemfile.lock/omniauth/open
