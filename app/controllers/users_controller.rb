# -*- coding: utf-8 -*-
class UsersController < ApplicationController

  before_filter :find_user, :except => [ :index, :new, :create ]

  def index
    @users = User.all
  end

  def show
    if @user
      @profile_fields = @user.profile_fields
      @title = @user.name
    
      # Profilfelder sinnvoll gruppieren
      @profile_field_groups = { 
        'Kontaktinformationen' => profile_fields_of_one_of_these_types( [ "Address", "Email", "Custom" ] ),
        'Über mich' => profile_fields_of_this_type( "About" ),
        'Informationen zum Studium' => profile_fields_of_this_type( "Study" ),
        'Informationen zum Beruf' => profile_fields_of_one_of_these_types( [ "Job", "Competence" ] ),
        'Vereine und Organisationen' => profile_fields_of_this_type( "Organisation" ),
      }
    else
      @title = "Benutzer: #{@alias}"
      @profile_field_groups = {}
    end
  end

  def new
    @title = t :create_user
    @user = User.new
    @user.alias = params[:alias]
    @ask_for_attributes = [ :first_name, :last_name, :alias, :email ]
  end

  def create
    @user = User.new( params[:user] )
    if @user.save
      redirect_to :action => "show", :alias => @user.alias
    else
      @title = t :create_user
      @user.valid?
      @ask_for_attributes = [ :first_name, :last_name, :alias, :email ]
      render :action => "new"
      "Test"
    end
  end

  private

  def profile_fields_of_one_of_these_types ( types )
    @profile_fields.select { |profile_field|  types.include? profile_field.type }
  end

  def profile_fields_of_this_type ( type ) 
    profile_fields_of_one_of_these_types ( [ type ] )
  end

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

end
