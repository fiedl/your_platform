
# Die Einbindung dieses Moduls erfolgt in einem Initializer: config/initializers/active_record_navable_extension.rb.
module Profileable
  def has_profile_fields
    is_profileable
  end

  def is_profileable
    has_many :profile_fields, as: :profileable, dependent: :destroy, autosave: true
#    attr_accessor :email
    include InstanceMethodsForProfileables
    include SessionsHelper
  end

  module InstanceMethodsForProfileables
    
    def email
      profile_fields_by_type( "Email" ).first.value if profile_fields_by_type( "Email" ).first
    end
    def email=( email )
      @email_profile_field = profile_fields_by_type( "Email" ).first unless @email_profile_field
      @email_profile_field = profile_fields.build( type: "Email", label: "E-Mail" ) unless @email_profile_field
      @email_profile_field.value = email
    end

    def sections
      [:contact_information, :about_myself, :study_information, :career_information, 
       :organizations, :bank_account_information, :description]
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
      when :organizations
        profile_fields_by_type "Organization"
      when :bank_account_information
        profile_fields_by_type "BankAccount"
      when :description
        profile_fields_by_type "Description"
      else
        []
      end
    end

    def profile_field_type_by_section(section)
      case section
        when :contact_information
          [ "Address", "Email", "Phone", "Homepage", "Custom" ]
        when :about_myself
          "About"
        when :study_information
          "Study"
        when :career_information
          [ "Job", "Competence" ]
        when :organizations
          "Organization"
        when :bank_account_information
          "BankAccount"
        when :description
          "Description"
        else
          []
      end
    end

  end
 
end
