concern :ProfileSections do

  def profile_section_titles
    self.class.profile_section_titles
  end

  def profile_sections
    self.profile.sections
  end

  def profile_fields_by_type( type_or_types )
    profile_fields.where( type: type_or_types )
  end

  class_methods do

    def profile_section_titles
      [:contact_information, :about_myself, :study_information, :career_information,
        :organizations, :bank_account_information, :description]
    end

  end

end