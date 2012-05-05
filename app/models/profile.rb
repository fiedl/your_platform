# -*- coding: utf-8 -*-
class Profile #< ActiveRecord::Base
  # attr_accessible :title, :body

  #belongs_to            :user

  #has_many              :profile_fields

  def initialize( user )
    @user = user
  end

  def fields
    ProfileField.find( :all, :conditions => "user_id = '#{@user.id}'" )
  end

  def email
    begin
      @email = email_field.value unless @email
    rescue
      @email = nil
    end
    return @email
  end
  def email=( email )
    @email = email
    # Dieser Wert wird erst später gepspeichert, wenn ein save() aufgerufen wird.
    
    # TODO: Hier ist die Frage, wie das getriggert wird, nachdem dies kein echter ActiveRecord ist. 
  end

  def fields_of_one_of_these_types ( types )
    fields.select { |profile_field|  types.include? profile_field.type }
  end

  def fields_of_this_type ( type )
    fields_of_one_of_these_types ( [ type ] )
  end

  # Um die Profilfelder sinnvoll zu gruppieren, können sie in mehrere Abschnitte (sections) untergliedert
  # abgefragt werden. 
  # Diese Funktion gibt ein assoziatives Array zurück, wobei der Schlüssel der Titel des Abschnittes ist,
  # der Wert ein Array der entsprechenden Profilfelder.
  def sections
    {
      :contact_information      =>  fields_of_one_of_these_types( [ "Address", "Email", "Custom" ] ),
      :about_myself             =>  fields_of_this_type( "About" ),
      :study_information        =>  fields_of_this_type( "Study" ),
      :career_information       =>  fields_of_one_of_these_types( [ "Job", "Competence" ] ),
      :organisations            =>  fields_of_this_type( "Organisation" ),
    }
  end



  def save
    if @email
      unless @email.blank?
        pf = email_field
        unless pf
          pf = ProfileField.new( :user_id => @user.id, :type => "Email", :label => I18n.t( :email ) )
        end
        unless pf.value == @email
          pf.value = @email
          pf.save
        end
      end
    end
  end

  private

  def email_field
    ProfileField.find( :first, :conditions => "user_id='#{@user.id}' AND type='Email'" ) 
  end

end
