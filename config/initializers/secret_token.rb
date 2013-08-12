# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
#
# The secrets file is only available in production. 
# Therefore, development and test just use 30 'x' characters.
#
# http://daniel.fone.net.nz/blog/2013/05/20/a-better-way-to-manage-the-rails-secret-token/
#

Wingolfsplattform::Application.config.secret_token = if Rails.env.production?
   ::SECRETS['secret_token']
else
  ('x' * 30) # meets minimum requirement of 30 chars long
end
