# -*- coding: utf-8 -*-
class SessionsController < ApplicationController

  # Die Session-Variablen @session und @current_user werden in app/controller/applicationcontroller.rb gefüllt
  # und sind dann für alle Controller verfügbar.

  def new
    @title = t :login
  end

  def create
    @title = t :login
    begin
      @current_user = User.authenticate( params[ :login_name ], params[ :password ] )
      if @current_user
        @session.current_user = @current_user
        redirect_to :controller => "users", :action => "show", :alias => @current_user.alias
      end
    rescue => exception
      flash[ :error ] = t exception
      render :action => "new"
    end
  end

  def destroy
    @session.destroy
    flash[ :notice ] = t :good_bye
    redirect_to :action => "new"
  end

end

