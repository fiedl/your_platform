require_dependency Refile::Engine.root.join('lib/refile/app').to_s

# This is a patch for:
# https://github.com/refile/refile/blob/master/lib/refile/app.rb
#
# According to https://github.com/refile/refile/issues/185#issuecomment-226692684,
# this fixes the "Can't verify CSRF token authenticity" bug.
#
class Refile::App

  configure do
    set :sessions, true
  end

end