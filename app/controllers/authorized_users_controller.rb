# This controller provides a way to find out if one or several users are allowed
# to access a certain resource.
#
# For example, this is used for the access indicator: List all users that can read
# this post, page, etc.
#
class AuthorizedUsersController < ApplicationController
  skip_authorize_resource only: :index

  def index
    authorize! :read, resource
    @users = User.all.select { |user| Ability.new(user).can? right, resource }
  end

  private

  def resource
    @resource ||= GlobalID::Locator.locate(params[:resource]) || raise(ActionController::ParameterMissing, 'resource not given')
  end

  def right
    @right ||= params[:right].try(:to_sym) || :read
  end

end