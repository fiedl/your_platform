require 'open-uri'
require 'base64'

# This module contains all the Avatar-related methods of a User.
# The avatar feature is done using the refile gem.
#
# Have a look at:
# * https://www.gorails.com/episodes/file-uploads-with-refile
# * https://github.com/refile/refile
#
concern :UserAvatar do

  included do
    attachment :avatar, type: :image
  end

  def avatar_base64
    # http://stackoverflow.com/a/1547631/2066546
    Base64.encode64(avatar_file_content).gsub(" ", "")
  end

  def avatar_file_content
    open(avatar_url) { |io| io.read }
  end

  def avatar_url
    AppVersion.root_url + avatar_path
  end

  def avatar_path
    "/api/v1/users/#{id}/avatar"
  end

end