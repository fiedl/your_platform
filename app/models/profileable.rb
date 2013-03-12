
# Die Einbindung dieses Moduls erfolgt in einem Initializer: config/initializers/active_record_navable_extension.rb.
module Profileable
  def has_profile_fields
    is_profileable
  end

  def is_profileable
    has_many :profile_fields, as: :profileable, dependent: :destroy, autosave: true
#    attr_accessor :email
    include InstanceMethodsForProfileables
  end

  module InstanceMethodsForProfileables
    
    def email
      profile_fields_by_type( "ProfileFieldTypes::Email" ).first.value if profile_fields_by_type( "ProfileFieldTypes::Email" ).first
    end
    def email=( email )
      @email_profile_field = profile_fields_by_type( "ProfileFieldTypes::Email" ).first unless @email_profile_field
      @email_profile_field = profile_fields.build( type: "ProfileFieldTypes::Email", label: "E-Mail" ) unless @email_profile_field
      @email_profile_field.value = email
    end

    def sections
      [:contact_information, :about_myself, :study_information, :career_information, 
       :organizations, :bank_account_information, :description]
    end

    def profile_fields_by_type( type_or_types )
      types = type_or_types if type_or_types.kind_of? Array
      types = [ type_or_types ] unless types
      profile_fields.where( type: types )
#      profile_fields.select { |profile_field| types.include? profile_field.type }
    end
    
    def profile_fields_by_section( section )
      case section
      when :contact_information
        profile_fields_by_type [ "ProfileFieldTypes::Address", "ProfileFieldTypes::Email", 
                                 "ProfileFieldTypes::Phone", "ProfileFieldTypes::Homepage", 
                                 "ProfileFieldTypes::Custom" ]
      when :about_myself
        profile_fields_by_type "ProfileFieldTypes::About"
      when :study_information
        profile_fields_by_type "ProfileFieldTypes::Study"
      when :career_information
        profile_fields_by_type [ "ProfileFieldTypes::Job", "ProfileFieldTypes::Competence" ]
      when :organizations
        profile_fields_by_type "ProfileFieldTypes::Organization"
      when :bank_account_information
        profile_fields_by_type "ProfileFieldTypes::BankAccount"
      when :description
        profile_fields_by_type "ProfileFieldTypes::Description"
      else
        []
      end
    end

    def profile_field_type_by_section(section)
      case section
        when :contact_information
          [ "ProfileFieldTypes::Address", "ProfileFieldTypes::Email", 
            "ProfileFieldTypes::Phone", "ProfileFieldTypes::Homepage", "ProfileFieldTypes::Custom" ]
        when :about_myself
          "ProfileFieldTypes::About"
        when :study_information
          "ProfileFieldTypes::Study"
        when :career_information
          [ "ProfileFieldTypes::Job", "ProfileFieldTypes::Competence" ]
        when :organizations
          "ProfileFieldTypes::Organization"
        when :bank_account_information
          "ProfileFieldTypes::BankAccount"
        when :description
          "ProfileFieldTypes::Description"
        else
          []
      end
    end

  end
 
end
