# -*- coding: utf-8 -*-
class UsersController < ApplicationController

  before_filter :find_user, :except => [ :index, :new, :create ]
  before_filter :define_form, only: [ :new, :create ]

  def index
    @users = User.all
  end

  def show
    id = @user.id if @user
    redirect_to controller: 'profiles', action: 'show', id: id
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
      "Test"
    end
  end

  private

  def find_user
    @alias = params[ :alias ]
    id = params[ :id ]
    if @alias
      @user = User.find_by_alias( @alias ) #User.find( :first, :conditions => "alias='#{@alias}'" )
    elsif id
      @user = User.find_by_id( id )
    else
      @user = User.new
    end
  end

  def define_form
    @ask_for_attributes = [ :first_name, :last_name, :alias, :email, :create_account ]
  end

end
