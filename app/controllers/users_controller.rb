# -*- coding: utf-8 -*-
class UsersController < ApplicationController

  respond_to :html, :json
  before_filter :find_user, only: [ :show, :update ]

  def index
    redirect_to Group.jeder
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      #format.json { render json: @profile.sections }  # TODO
    end
  end

  def new
    @title = t :create_user
    @user = User.new
    @user.alias = params[:alias]
    
  end

  def create
    @user = User.new( params[:user] )
    if @user.save
      redirect_to :action => "show", :alias => @user.alias
    else
      @title = t :create_user
      @user.valid?
      render :action => "new"
    end
  end

  def update
    @user.update_attributes( params[ :user ] )
    respond_with @user
  end

  def autocomplete_title
    term = params[ :term ]
    @users = User.all.select { |user| user.title.downcase.include? term.downcase }
    render json: json_for_autocomplete( @users, :title )
  end


  private

  def find_user
    @user = User.find( params[ :id ] )
    @user = User.new unless @user
    @title = @user.title
    @navable = @user
  end

end
