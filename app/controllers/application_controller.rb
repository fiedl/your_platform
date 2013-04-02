# -*- coding: utf-8 -*-
class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter      :http_authenticate

  layout             :find_layout

  protected

  def http_authenticate
    return true if ENV[ 'RAILS_ENV' ] == 'test'
    authenticate_or_request_with_http_basic do |username, password|
      username == "aki" && password == "deleted-string"
    end
  end

  def find_layout
    layout = "bootstrap"
    if params[ :layout ]
      layout = params[ :layout ] 
    end
    return layout
  end

end
