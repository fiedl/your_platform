# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter      :http_authenticate
  before_filter      :initialize_session

  helper_method      :logged_in?

  protected

  def http_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "aki" && password == "deleted-string"
    end
  end

  def initialize_session
    @session = Session.new( session, cookies, request )   # in controller/sessions_controller.rb
                            # session ist die Session-Variable, die vom ActionController zur Verfügung gestellt wird.
                            # cookies ist die entsprechende Cookies-Variable.
                            # reuest ist die Request-Instanz, die eine Methode zum Rest der Session enthält.
    @current_user = @session.current_user
  end

  def logged_in?
    @session.logged_in?
  end

end
