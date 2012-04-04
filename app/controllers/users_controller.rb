# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    _alias = params[:alias]
    @user = User.find( :first, :conditions => "alias='#{_alias}'" )

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
      @title = "Benutzer: #{_alias}"
      @profile_field_groups = {}
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
