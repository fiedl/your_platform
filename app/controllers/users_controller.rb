# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @alias = params[:alias]
    if @alias
      @user = User.find( :first, :conditions => "alias='#{@alias}'" )
    else
      @user = User.find_by_id( params[:id] )
    end

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
    @title = "Benutzer anlegen"
    @user = User.new
    @user.alias = params[:alias]
    
    # Eigentlich möchte ich das automatisch erstellen lassen im View. Aber es klappt noch nicht richtig. 
    # @form_fields = {
    #  :first_name => {},
    #  :last_name => {},
    #  :alias => {},
    #  :email => {},
    # }
  end

  def create
    @user = User.new( params[:user] )
    if @user.save
      redirect_to :action => "show", :alias => @user.alias
    else
      render :action => "new"
    end
  end

  private

  def profile_fields_of_one_of_these_types ( types )
    @profile_fields.select { |profile_field|  types.include? profile_field.type }
  end

  def profile_fields_of_this_type ( type ) 
    profile_fields_of_one_of_these_types ( [ type ] )
  end

end
