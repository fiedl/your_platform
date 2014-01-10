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
    self.alias = netenv_user.alias || netenv_user.w_nummer
    self.save!
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
      if netenv_user.erstes_fachsemester.present?
        add_profile_field :study, from: netenv_user.erstes_studiensemester, subject: "Studium #{netenv_user.educational_area}", type: 'Study'
      end
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
    label = ( netenv_user.professional_categories.count > 1 ? :professional_categories : :professional_category )
    add_profile_field label, value: netenv_user.professional_categories.join(", "), type: 'ProfessionalCategory'
    
    # Tätigkeitsbereiche
    label = ( netenv_user.occupational_areas.count > 1 ? :occupational_areas : :occupational_area )
    add_profile_field label, value: netenv_user.occupational_areas.join(", "), type: 'ProfessionalCategory'
    
    # Tätigkeit (Freitext)
    add_profile_field :activity, value: netenv_user.activity_freetext, type: 'ProfessionalCategory'
    
    # Sprachen
    netenv_user.native_languages.each do |language|
      add_profile_field :native_language, value: language, type: 'Competence'
    end
    netenv_user.language_skills.each do |language|
      add_profile_field :language, value: language, type: 'Competence'
    end
    
    # Berufliche Erfahrung als: Berufsberater, Entwickler, Projektleiter
    netenv_user.professional_experiences.each do |experience|
      add_profile_field :experience_as, value: experience, type: 'Competence'
    end
    
    # Weitere Fertigkeiten
    netenv_user.general_skills.each do |skill|
      add_profile_field :skill, value: skill, type: 'Competence'
    end
    
    # Angebote
    netenv_user.offerings.each do |offering|
      add_profile_field :i_offer, value: offering, type: 'Competence'
    end
    add_profile_field :i_offer_talk_about, value: netenv_user.offering_talk_about, type: 'Competence'  # Vortrag zum Thema
    add_profile_field :i_offer_training, value: netenv_user.offering_training, type: 'Competence'  # Praktika
    add_profile_field :i_offer, value: netenv_user.offering_freetext, type: 'Competence'
    
    # Gesuche
    netenv_user.requests.each do |request|
      add_profile_field :request, value: "Ich suche: #{request}", type: 'Competence'
    end
    add_profile_field :request, value: netenv_user.request_freetext, type: 'Competence'
    
  end
  
  def import_bank_profile_fields_from( netenv_user )
    add_profile_field :bank_account, netenv_user.bank_account.merge({ type: 'BankAccount' })
  end
  
  def import_communication_profile_fields_from( netenv_user )
    
    # Wingolfsblätter ja/nein
    self.wingolfsblaetter_abo = netenv_user.wbl_abo?
    
    # Namensfeld für Wingolfspost
    add_profile_field :name_field_wingolfspost, text_above_name: netenv_user.text_above_name, name_prefix: netenv_user.name_prefix, name_suffix: netenv_user.name_suffix, text_below_name: netenv_user.text_below_name, type: 'NameSurrounding'

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
  
  
  # Mitgliedschaft in Korporationen
  # =======================================================================
  
  def import_corporation_memberships_from( netenv_user )
    self.reset_corporation_memberships
    self.import_primary_corporation_from netenv_user
  end
  
  def reset_corporation_memberships
    (self.parent_groups & Group.corporations_parent.descendant_groups).each do |group|
      UserGroupMembership.with_invalid.find_by_user_and_group(self, group).destroy
    end
  end
  
  def import_primary_corporation_from( netenv_user )
    
    corporation = netenv_user.primary_corporation
    
    # Aktivmeldung
    raise 'no aktivmeldungsdatum given.' unless netenv_user.aktivmeldungsdatum
    hospitanten = corporation.status_group("Hospitanten")
    membership_hospitanten = hospitanten.assign_user self, at: netenv_user.aktivmeldungsdatum
    
    # Reception
    if netenv_user.receptionsdatum
      krassfuxen = corporation.status_group("Kraßfuxen")
      membership_krassfuxen = membership_hospitanten.promote_to krassfuxen, at: netenv_user.receptionsdatum
    end
    
    # Burschung
    if netenv_user.burschungsdatum
      burschen = corporation.status_group("Aktive Burschen")
      current_membership = self.reload.current_status_membership_in corporation
      membership_burschen = current_membership.promote_to burschen, at: netenv_user.burschungsdatum
    end
    
    
    
  end
  
    
end
