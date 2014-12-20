# -*- coding: utf-8 -*-

# This extends the your_platform User model.
require_dependency YourPlatform::Engine.root.join( 'app/models/user' ).to_s

# This class represents a user of the platform. A user may or may not have an account.
# While the most part of the user class is contained in the your_platform engine, 
# this re-opened class contains all wingolf-specific additions to the user model.
#
class User
  attr_accessible :wingolfsblaetter_abo, :hidden
  
  # This method is called by a nightly rake task to renew the cache of this object.
  #
  def fill_cache
    aktivitaetszahl
    name_affix
    title
    
    bv
    bv_membership
    w_nummer
    aktiver?
    philister?
    
    date_of_birth
    date_of_death  
    birthday_this_year
    age
    
    postal_address
    address_label
    postal_address_updated_at
    
    corporations
    current_corporations
    sorted_current_corporations
    my_groups_in_first_corporation
    
    for corporation in corporations
      corporate_vita_memberships_in corporation
    end
    
    hidden
    personal_title
    academic_degree
    
    administrated_aktivitates
  end

  # This method returns a kind of label for the user, e.g. for menu items representing the user.
  # Use this rather than the name attribute itself, since the title method is likely to be overridden
  # in the main application.
  # Notice: This method does *not* return the academic title of the user.
  # 
  # Here, title returns the name and the aktivitaetszahl, e.g. "Max Mustermann E10 H12".
  # 
  def title
    cached { "#{name} #{name_affix}".gsub("  ", " ").strip }
  end
  
  def name_affix
    cached { "#{aktivitaetszahl} #{string_for_death_symbol}".gsub("  ", " ").strip }
  end
  
  # For dead users, there is a cross symbol in the title.
  # (✝,✞,✟)
  # 
  # More characters in this table:
  # http://www.utf8-chartable.de/unicode-utf8-table.pl?start=9984&names=2&utf8=-&unicodeinhtml=hex
  # 
  def string_for_death_symbol
    "(✟)" if dead?
  end
  
  # This method returns the bv (Bezirksverband) the user is associated with.
  #
  def bv
    cached { (Bv.all & self.groups).try(:first).try(:becomes, Bv) }
  end
  
  def bv_membership
    cached { UserGroupMembership.find_by_user_and_group(self, bv) if bv }
  end
  
  # Diese Methode gibt die BVs zurück, denen der Benutzer zugewiesen ist. In der Regel
  # ist jeder Philister genau einem BV zugeordnet. Durch Fehler kann es jedoch dazu kommen,
  # dass er mehreren BVs zugeordnet ist.
  #
  def bv_memberships
    (Bv.all & self.groups).collect do |bv|
      UserGroupMembership.find_by_user_and_group(self, bv)
    end - [nil]
  end
  
  def bv_beitrittsdatum
    bv_membership.valid_from if bv
  end
  
  # Diese Methode gibt den BV zurück, dem der Benutzer aufgrund seiner Postanschrift
  # zugeordnet sein sollte. Der eingetragene BV kann und darf davon abweisen, da er
  # in Sonderfällen auch händisch zugewiesen werden kann.
  #
  # Achtung: Nur Philister sind BVs zugeordnet. Wenn der Benutzer Aktiver ist,
  # gibt diese Methode `nil` zurück.
  #
  def correct_bv
    if self.philister? 
      if postal_address_field_or_first_address_field.try(:value).try(:present?)
        postal_address_field_or_first_address_field.bv
      else
        # Wenn keine Adresse gegeben ist, in den BV 00 (Unbekannt Verzogen) verschieben.
        Bv.find_by_token("BV 00")
      end
    end
  end
  
  # Diese Methode passt den BV des Benutzers der aktuellen Postanschrift an.
  # Achtung: Nur Philister sind BVs zugeordnet. Wenn der Benutzer Aktiver ist,
  # tut diese Methode nichts.
  #
  def adapt_bv_to_postal_address
    self.groups(true) # reload groups
    new_bv = correct_bv
    
    # Fall 0: Es konnte kein neuer BV identifiziert werden.
    # In diesem Fall wird aus Konsistenzgründen die aktuelle BV-Mitgliedschaft
    # zurückgegeben, da der BV dann nicht verändert werden soll.
    #
    if not new_bv
      new_membership = self.bv_membership
    
    # Fall 1: Es ist noch kein BV zugewiesen. Es wird schlicht der neue zugewiesen.
    #
    elsif new_bv and not bv
      new_membership = new_bv.assign_user self

    # Fall 2: Es ist bereits ein BV zugewiesen. Der neue BV ist auch der alte
    # BV. Die Mitgliedschaft muss also nicht geändert werden.
    #
    elsif new_bv and (new_bv == bv)
      new_membership = self.bv_membership

    # Fall 3: Es ist bereits ein BV zugewiesen. Der neue BV weicht davon ab.
    # Die Mitgliedschaft muss also geändert werden.
    #
    elsif new_bv and bv and (new_bv != bv)

      # FIXME: For the moment, DagLinks have to be unique. Therefore, the old 
      # membership has to be destroyed if the user previously had been a member
      # of the new bv. When DagLinks are allowed to exist several times, remove
      # this hack:
      #
      if old_membership = UserGroupMembership.now_and_in_the_past.find_by_user_and_group(self, new_bv)
        if old_membership != self.bv_membership
          old_membership.destroy
        end
      end

      new_membership = self.bv_membership.move_to new_bv
    end
    
    # Korrekturlauf: Durch einen Fehler kann es sein, dass ein Benutzer mehreren
    # BVs zugeordnet ist. Deshalb werden hier die übrigen BV-Mitgliedschaften
    # deaktiviert, damit er nur noch dem neuen BV zugeordnet ist.
    #
    for membership in self.bv_memberships
      membership.invalidate at: 1.minute.ago if membership != new_membership
    end
    
    # Cache zurücksetzen
    self.delay.delete_cached :bv
    self.delay.delete_cached :bv_membership

    self.groups(true) # reload groups
    return new_membership
  end

  # This method returns the aktivitaetszahl of the user, e.g. "E10 H12".
  #
  def aktivitaetszahl
    cached do 
      self.corporations
        .select { |corporation| role = Role.of(self).in(corporation); role.full_member? or role.deceased_member? }
        .collect { |corporation| {string: aktivitaetszahl_for(corporation), year: aktivitaetszahl_year_for(corporation)} }
        .sort_by { |hash| hash[:year] }  # Sort by the year of joining the corporation.
        .collect { |hash| hash[:string] }.join(" ")
    end
  end

  def aktivitätszahl
    aktivitaetszahl
  end
  
  def aktivitaetszahl_for(corporation)
    "#{corporation.token} #{aktivitaetszahl_addition_for(corporation)} #{aktivitaetszahl_short_year_for(corporation)}".gsub('  ', '').strip
  end

  def aktivitaetszahl_year_for(corporation)
    (corporation.status_groups.collect { |status_group| status_group.membership_of(self, also_in_the_past: true).try(:valid_from) } - [nil]).min.to_s[0, 4]
  end
  def aktivitaetszahl_short_year_for(corporation)
    aktivitaetszahl_year_for(corporation)[2, 2]
  end

  def aktivitaetszahl_addition_for(corporation)
    addition = ""
    addition += " Stft" if self.member_of? corporation.descendant_groups.find_by_name("Stifter"), also_in_the_past: true
    addition += " Nstft" if self.member_of? corporation.descendant_groups.find_by_name("Neustifter"), also_in_the_past: true
    addition += " Eph" if self.member_of? corporation.descendant_groups.find_by_name("Ehrenphilister"), also_in_the_past: true
    addition += " " if addition != ""
    return addition.strip
  end
  
  def klammerung
    self.profile_fields.where(label: :klammerung).first.try(:value)
  end
  
  def aktivmeldungsdatum
    first_corporation.try(:membership_of, self).try(:valid_from).try(:to_date)
  end
  def aktivmeldungsdatum=(date)
    (first_corporation || raise('user is not member of a corporation')).membership_of(self).update_attribute(:valid_from, date.to_datetime)
  end
  

  # Fill-in default profile.
  #
  def fill_in_template_profile_information
    self.profile_fields.create(label: :personal_title, type: "ProfileFieldTypes::General")
    self.profile_fields.create(label: :academic_degree, type: "ProfileFieldTypes::AcademicDegree")
    self.profile_fields.create(label: :cognomen, type: "ProfileFieldTypes::General")
    self.profile_fields.create(label: :klammerung, type: "ProfileFieldTypes::Klammerung")

    self.profile_fields.create(label: :home_address, type: "ProfileFieldTypes::Address") unless self.home_address
    self.profile_fields.create(label: :work_or_study_address, type: "ProfileFieldTypes::Address") unless self.work_or_study_address
    self.profile_fields.create(label: :phone, type: "ProfileFieldTypes::Phone") unless self.phone
    self.profile_fields.create(label: :mobile, type: "ProfileFieldTypes::Phone") unless self.mobile
    self.profile_fields.create(label: :fax, type: "ProfileFieldTypes::Phone")
    self.profile_fields.create(label: :homepage, type: "ProfileFieldTypes::Homepage")

    pf = self.profile_fields.build(label: :study, type: "ProfileFieldTypes::Study")
    pf.becomes(ProfileFieldTypes::Study).save

    self.profile_fields.create(label: :professional_category, type: "ProfileFieldTypes::ProfessionalCategory")
    self.profile_fields.create(label: :occupational_area, type: "ProfileFieldTypes::ProfessionalCategory")
    self.profile_fields.create(label: :employment_status, type: "ProfileFieldTypes::ProfessionalCategory")
    self.profile_fields.create(label: :languages, type: "ProfileFieldTypes::Competence")
    
    pf = self.profile_fields.build(label: :bank_account, type: "ProfileFieldTypes::BankAccount")
    pf.becomes(ProfileFieldTypes::BankAccount).save

    pf = self.profile_fields.create(label: :name_field_wingolfspost, type: "ProfileFieldTypes::NameSurrounding")
      .becomes(ProfileFieldTypes::NameSurrounding)
    pf.text_above_name = ""; pf.name_prefix = "Herrn"; pf.name_suffix = ""; pf.text_below_name = ""
    pf.save

    self.wingolfsblaetter_abo = true
  end
  
  
  # W-Nummer  (old uid)
  # ==========================================================================================
  
  def w_nummer
    cached { self.profile_fields.where(label: "W-Nummer").first.try(:value) }
  end
  def w_nummer=(str)
    field = profile_fields.where(label: "W-Nummer").first || profile_fields.create(type: 'ProfileFieldTypes::General', label: 'W-Nummer')
    field.update_attribute(:value, str)
  end
  
  def self.find_by_w_nummer(wnr)
    ProfileField.where(label: "W-Nummer", value: wnr).last.try(:profileable)
  end
  
  
  # Wingolfit?
  # ==========================================================================================

  # This method checks whether the user classifies as wingolfit.
  #
  #   * Users who terminated their membership in wingolf are considered not to be wingolfit.
  #   * Users who died while being member are considered as wingolfit.
  #   * Users with hospitant status are considered as wingolfit.
  #   * Users with guest status are not considered as wingolfit.
  #
  # This all comes down to this: 
  # A user is a wingolfit if he has an aktivitätszahl.
  #
  def wingolfit?
    philister? || aktiver?
  end
  
  def aktiver?
    cached { Group.alle_aktiven.members.include? self }
  end
  
  def philister?
    cached { Group.alle_philister.members.include? self }
  end
  
  def group_names
    self.groups.collect { |group| group.name }
  end


  # Abo Wingolfsblätter
  # ==========================================================================================

  def wbl_abo_group
    Group.find_or_create_wbl_abo_group
  end
  private :wbl_abo_group

  def wingolfsblaetter_abo 
    self.member_of? wbl_abo_group
  end
  def wingolfsblaetter_abo=(new_abo_status)
    if new_abo_status == true || new_abo_status == "true"
      wbl_abo_group.assign_user self
    elsif new_abo_status == false || new_abo_status == "false"
      wbl_abo_group.unassign_user self
    end
  end


  # Besondere Admin-Hilfs-Methoden
  
  def administrated_aktivitates
    cached { Role.of(self).administrated_aktivitates }
  end
  
end

