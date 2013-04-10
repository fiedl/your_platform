class ErrorsController < ApplicationController

  skip_authorization_check

  def unauthorized
  end
end
