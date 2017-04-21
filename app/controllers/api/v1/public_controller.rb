# The public API endpoint controllers inherit from this class.
# No authentication is required for the public API endpoints.
#
# For api documentation, see /api.
#
class Api::V1::PublicController < ApplicationController

  before_action :allow_cross_origin_requests

  # Add the Cross-origin resource sharing header for public requests.
  #
  def allow_cross_origin_requests
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

end