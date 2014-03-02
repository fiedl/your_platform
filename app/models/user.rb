# -*- coding: utf-8 -*-

# This extends the your_platform User model.
require_dependency YourPlatform::Engine.root.join( 'app/models/user' ).to_s

# This class represents a user of the platform. A user may or may not have an account.
# While the most part of the user class is contained in the your_platform engine, 
# this re-opened class contains all wingolf-specific additions to the user model.
#
class User
  attr_accessible :wingolfsblaetter_abo, :hidden


  # This method returns a kind of label for the user, e.g. for menu items representing the user.
  # Use this rather than the name attribute itself, since the title method is likely to be overridden
  # in the main application.
  # Notice: This method does *not* return the academic title of the user.
  # 
  # Here, title returns the name and the aktivitaetszahl, e.g. "Max Mustermann E10 H12".
  # 
  def title
    "#{name} #{cached_aktivitaetszahl} #{string_for_death_symbol}".gsub("  ", " ").strip
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
    (Bv.all & self.groups).try(:first).try(:becomes, Bv)
  end
  
  def bv_membership
    UserGroupMembership.find_by_user_and_group(self, bv) if bv
  end
  
  def bv_beitrittsdatum
    bv_membership.valid_from if bv
  end
  
  # Diese Methode passt den BV des Benutzers der aktuellen Postanschrift an.
  # Achtung: Nur Philister sind BVs zugeordnet. Wenn der Benutzer Aktiver ist,
  # tut diese Methode nichts.
  #
  def adapt_bv_to_postal_address
    self.groups(true) # reload groups
    if self.philister?
      new_bv = postal_address_field_or_first_address_field.bv
      if new_bv and bv and (new_bv != bv)
        
        # FIXME: For the moment, DagLinks have to be unique. Therefore, the old 
        # membership has to be destroyed if the user previously had been a member
        # of the new bv. When DagLinks are allowed to exist several times, remove
        # this hack:
        #
        if old_membership = UserGroupMembership.now_and_in_the_past.find_by_user_and_group(self, new_bv)
          if old_membership != bv_membership
            old_membership.destroy
          end
        end
        
        new_membership = self.bv_membership.move_to new_bv
      elsif new_bv and not bv
        new_membership = new_bv.assign_user self
      end
      self.groups(true) # reload groups
    end
  end

  # This method returns the aktivitaetszahl of the user, e.g. "E10 H12".
  #
  def aktivitätszahl
    if self.corporations
      self.corporations
      .select do |corporation|
        not (self.guest_of?(corporation)) and
        not (self.former_member_of_corporation?(corporation)) and
        corporation.membership_of(self).valid_from
      end.sort_by { |corporation| corporation.membership_of(self).valid_from } # order by date of joining
      .collect do |corporation|
        year_of_joining = ""
        year_of_joining = corporation.membership_of( self ).valid_from.to_s[2, 2] if corporation.membership_of( self ).valid_from
        #corporation.token + "\u2009" + year_of_joining
        token = corporation.token; token ||= ""
        token + aktivitaetszahl_addition_for(corporation) + year_of_joining
      end.join(" ")
    end
  end
  def aktivitaetszahl
    aktivitätszahl
  end

  def cached_aktivitaetszahl
    Rails.cache.fetch([self, "aktivitaetszahl"]) { aktivitaetszahl }
  end
  
  def aktivitaetszahl_addition_for( corporation )
    addition = ""
    addition += " Stft" if self.member_of? corporation.descendant_groups.find_by_name("Stifter"), also_in_the_past: true
    addition += " Nstft" if self.member_of? corporation.descendant_groups.find_by_name("Neustifter"), also_in_the_past: true
    addition += " Eph" if self.member_of? corporation.descendant_groups.find_by_name("Ehrenphilister"), also_in_the_past: true
    addition += " " if addition != ""
    return addition
  end

  # Fill-in default profile.
  #
  def fill_in_template_profile_information
    self.profile_fields.create(label: :personal_title, type: "ProfileFieldTypes::General")
    self.profile_fields.create(label: :academic_degree, type: "ProfileFieldTypes::AcademicDegree")
    self.profile_fields.create(label: :cognomen, type: "ProfileFieldTypes::General")
    self.profile_fields.create(label: :klammerung, type: "ProfileFieldTypes::Klammerung")

    self.profile_fields.create(label: :home_address, type: "ProfileFieldTypes::Address")
    self.profile_fields.create(label: :work_or_study_address, type: "ProfileFieldTypes::Address")
    self.profile_fields.create(label: :phone, type: "ProfileFieldTypes::Phone")
    self.profile_fields.create(label: :mobile, type: "ProfileFieldTypes::Phone")
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
    self.profile_fields.where(label: "W-Nummer").first.try(:value)
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
    self.aktivitätszahl.present?
  end
  
  def aktiver?
    (group_names & ["Aktivitas", "Activitas"]).count > 0
  end
  
  def philister?
    group_names.include? "Philisterschaft"
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


  # Global Admin Switch
  # ==========================================================================================

  def global_admin
    self.in? Group.everyone.admins
  end
  def global_admin?
    self.global_admin
  end
  def global_admin=(new_setting)
    if new_setting == true
      Group.everyone.admins << self
    else
      UserGroupMembership.find_by_user_and_group(self, Group.everyone.main_admins_parent).try(:destroy)
      UserGroupMembership.find_by_user_and_group(self, Group.everyone.admins_parent).try(:destroy)
    end
  end

end

