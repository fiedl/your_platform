class ProfileSection < Struct.new(:title, :profileable)

  def initialize( options = {} )
    self.title = options[:title] || raise('missing option "title"')
    self.profileable = options[:profileable] || raise('missing option "profileable"')
  end
  
  def profile_fields
    profileable.profile_fields.where( type: self.profile_field_types )
  end
  def fields
    profile_fields
  end
  
  def profile_field_types
    case(self.title.to_sym)
      when :general
        [ "ProfileFieldTypes::AcademicDegree", "ProfileFieldTypes::General" ]
      when :contact_information
        [ "ProfileFieldTypes::Address", "ProfileFieldTypes::Email", "ProfileFieldTypes::MailingListEmail",
          "ProfileFieldTypes::Phone", "ProfileFieldTypes::Homepage", "ProfileFieldTypes::Custom" ]
      when :about_myself
        [ "ProfileFieldTypes::About" ]
      when :study_information
        [ "ProfileFieldTypes::Study" ]
      when :career_information
        [ "ProfileFieldTypes::Employment", "ProfileFieldTypes::ProfessionalCategory", "ProfileFieldTypes::Competence" ]
      when :organizations
        [ "ProfileFieldTypes::Organization" ]
      when :bank_account_information
        [ "ProfileFieldTypes::BankAccount" ]
      when :description
        [ "ProfileFieldTypes::Description" ]
      when :communication
        [ "ProfileFieldTypes::NameSurrounding" ]
      else
        []
    end
    
  end
  def field_types
    profile_field_types
  end
  
  def to_s
    self.title.to_s
  end
  
end
