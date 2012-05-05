# -*- coding: utf-8 -*-
class ProfilesController < ApplicationController

  before_filter          :find_user_and_his_profile, except: [ :index ]

  def index
    redirect_to controller: 'users', action: 'index'
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @profile.sections }
    end
  end

  private

  def find_user_and_his_profile
    @alias = params[ :alias ] if params[ :alias ]
    @user = User.find_by_alias( @alias ) if @alias # TODO: Die Alias-Erkennung hier löschen und dafür das gem für die schönen Urls benutzen.
    @user = User.find_by_id( params[ :id ] ) if params[ :id ] unless @user
    if @user
      @profile = @user.profile
      @navable = @user
      @title = @user.title

      # GoogleMaps-Anzeige
      unless @profile.fields_of_this_type( "Address" ).empty?
        @gmaps4rails_json = @profile.fields_of_this_type( "Address" ).to_gmaps4rails 
      end
    else
      @title = t :user_not_found
      @title += ": #{@alias}" if @alias
    end
  end

end
