require_dependency 'app/models/user'

class User
  
  # Allgemeine Attribute
  # =======================================================================
    
  # Grundlegende Attribute übernehmen, die zur Erstellung eines
  # Datensatzes notwendig sind.
  #
  # Vor- und Zuname, E-Mail-Adresse, Alias, W-Nummer, Geburtsdatum.
  # 
  def import_basic_attributes_from( netenv_user )
    self.first_name = netenv_user.first_name
    self.last_name = netenv_user.last_name
    self.email = netenv_user.email
    self.alias = netenv_user.alias if netenv_user.alias.present?
    self.save
    self.date_of_birth = netenv_user.date_of_birth
    self.add_profile_field 'W-Nummer', value: netenv_user.w_nummer, type: 'General' 
  end
  
  def import_timestamps_from( netenv_user )
    User.record_timestamps = false
    self.updated_at = netenv_user.updated_at
    self.created_at = netenv_user.created_at
    self.save
    User.record_timestamps = true
  end
  
  
  # Profilfelder
  # =======================================================================
    
  def import_general_profile_fields_from( netenv_user )
    # Name, Geburtsdatum bereits importiert.
    add_profile_field :former_name, value: netenv_user.former_name, type: 'General'
    add_profile_field :personal_title, value: netenv_user.personal_title, type: 'General', force: true
    add_profile_field :academic_degree, value: netenv_user.academic_degree, type: 'General', force: true
    add_profile_field :cognomen, value: netenv_user.cognomen, type: 'General', force: true
    add_profile_field :klammerung, value: netenv_user.klammerung, type: 'General', force: true
  end

  def import_contact_profile_fields_from( netenv_user )
    add_profile_field :home_email, value: netenv_user.home_email, type: 'Email' unless netenv_user.home_email == netenv_user.email
    add_profile_field :work_email, value: netenv_user.work_email, type: 'Email' unless netenv_user.work_email == netenv_user.email
    add_profile_field netenv_user.home_address_label, value: netenv_user.home_address, type: 'Address'
    add_profile_field netenv_user.work_address_label, value: netenv_user.work_address, type: 'Address'
    add_profile_field :home_phone, value: netenv_user.home_phone, type: 'Phone'
    add_profile_field :work_phone, value: netenv_user.work_phone, type: 'Phone'
    add_profile_field :mobile, value: netenv_user.mobile, type: 'Phone'
    add_profile_field :home_fax, value: netenv_user.home_fax, type: 'Phone'
    add_profile_field :work_fax, value: netenv_user.work_fax, type: 'Phone'
    add_profile_field :homepage, value: netenv_user.homepage, type: 'Homepage'
    add_profile_field :work_homepage, value: netenv_user.work_homepage, type: 'Homepage'
  end

  def import_study_profile_fields_from( netenv_user )
    if netenv_user.erstes_fachsemester == netenv_user.erstes_studiensemester
      add_profile_field :study, from: netenv_user.erstes_studiensemester, subject: "Studium #{netenv_user.educational_area}", type: 'Study'
    else
      add_profile_field :study, from: netenv_user.erstes_studiensemester, subject: "", type: 'Study'
      add_profile_field :further_study, from: netenv_user.erstes_fachsemester, subject: "Studium #{netenv_user.educational_area}", type: 'Study'
    end
  end
  
  def import_professional_profile_fields_from( netenv_user )
    
    # Beschäftigungsstatus
    add_profile_field :employment_status, value: netenv_user.employment_status, type: 'ProfessionalCategory'
    
    # Amtsbezeichnung
    add_profile_field :employment_title, value: netenv_user.employment_title, type: 'ProfessionalCategory'
    
    # Berufsgruppen
    netenv_user.professional_categories.each do |category|
      add_profile_field :professional_category, value: category, type: 'ProfessionalCategory'
    end
    
    # Tätigkeitsbereiche
    netenv_user.occupational_areas.each do |area|
      add_profile_field :occupational_area, value: area, type: 'ProfessionalCategory'
    end
    
    # Sprachen
    netenv_user.native_languages.each do |language|
      add_profile_field :native_language, value: language, type: 'Competence'
    end
    netenv_user.language_skills.each do |language|
      add_profile_field :language, value: language, type: 'Competence'
    end
    
    # Berufliche Erfahrung als: Berufsberater, Entwickler, Projektleiter
    professional_experiences.each do |experience|
      add_profile_field :experience_as, value: experience, type: 'Competence'
    end
    
    # Weitere Fertigkeiten
    netenv_user.general_skills.each do |skill|
      add_profile_field :skill, value: skill, type: 'Competence'
    end
    
  end
  
  def import_bank_profile_fields_from( netenv_user )
    # TODO: Bankverbindung
  end
  
  def import_communication_profile_fields_from( netenv_user )
    # TODO: Wingolfsblätter ja/nein
    # TODO: Namensfeld für Wingolfspost
  end
  
  def add_profile_field( label, args )
    raise 'no :type argument given' unless args[:type].present?
    args[:type] = "ProfileFieldTypes::#{args[:type]}" unless args[:type].start_with? "ProfileFieldTypes::"
    if (args[:force] or one_argument_present?(args))
      args.delete(:force)
      if not profile_field_exists?(label, args)
        self.profile_fields.create.import_attributes(args.merge( { label: label } ))
      end
    end
  end

  def one_argument_present?( args )
    args.except(:type).each do |key, value|
      return true if value.present?
    end
    return false
  end
  private :one_argument_present?
  
  def profile_field_exists?( label, args )
    self.profile_fields.where(label: label, value: args[:value], type: args[:type]).count > 0
  end
  private :profile_field_exists?
  
  # 
  # =======================================================================
  
  
    
end
