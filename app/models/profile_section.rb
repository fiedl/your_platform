class ProfileSection < Struct.new(:title, :profileable)

  def initialize( options = {} )
    self.title = options[:title] || raise(RuntimeError, 'missing option "title"')
    self.profileable = options[:profileable] || raise(RuntimeError, 'missing option "profileable"')
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
        [ "ProfileFields::AcademicDegree", "ProfileFields::General" ]
      when :contact_information
        [ "ProfileFields::Address", "ProfileFields::Email", "ProfileFields::MailingListEmail",
          "ProfileFields::Phone", "ProfileFields::Homepage", "ProfileFields::Custom" ]
      when :about_myself
        [ "ProfileFields::About" ]
      when :study_information
        [ "ProfileFields::Study" ]
      when :career_information
        [ "ProfileFields::Employment", "ProfileFields::ProfessionalCategory", "ProfileFields::Competence" ]
      when :organizations
        [ "ProfileFields::Organization" ]
      when :bank_account_information
        [ "ProfileFields::BankAccount" ]
      when :description
        [ "ProfileFields::Description" ]
      when :communication
        [ "ProfileFields::NameSurrounding" ]
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
