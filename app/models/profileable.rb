
# Die Einbindung dieses Moduls erfolgt in einem Initializer: config/initializers/active_record_navable_extension.rb.
module Profileable
  def has_profile_fields
    is_profileable
  end

  def is_profileable
    has_many :profile_fields, as: :profileable, dependent: :destroy, autosave: true
    include InstanceMethodsForProfileables
  end

  module InstanceMethodsForProfileables
    
    def email
      profile_fields_by_type( "Email" ).first.value
    end
    def email=( email )
      @email_profile_field = profile_fields_by_type( "Email" ).first unless @email_profile_field
      @email_profile_field = profile_fields.build( type: "Email", label: "E-Mail" ) unless @email_profile_field
      @email_profile_field.value = email
    end

    def profile_fields_by_type( type_or_types )
      types = type_or_types if type_or_types.kind_of? Array
      types = [ type_or_types ] unless types
      profile_fields.select { |profile_field| types.include? profile_field.type }
    end
    
    def profile_fields_by_section( section )
      case section
      when :contact_information
        profile_fields_by_type [ "Address", "Email", "Phone", "Homepage", "Custom" ]
      when :about_myself
        profile_fields_by_type "About"
      when :study_information
        profile_fields_by_type "Study"
      when :career_information
        profile_fields_by_type [ "Job", "Competence" ]
      when :organisations
        profile_fields_by_type "Organisation"
      when :bank_account_information
        profile_fields_by_type "BankAccount"
      when :description
        profile_fields_by_type "Description"
      else
        []
      end

    end

  end
 
end
