# -*- coding: utf-8 -*-

# This extends the your_platform User model.
require_dependency YourPlatform::Engine.root.join( 'app/models/user' ).to_s

# This class represents a user of the platform. A user may or may not have an account.
# While the most part of the user class is contained in the your_platform engine, 
# this re-opened class contains all wingolf-specific additions to the user model.
#
class User

  attr_accessible :wingolfsblaetter_abo

  # This method returns a kind of label for the user, e.g. for menu items representing the user.
  # Use this rather than the name attribute itself, since the title method is likely to be overridden
  # in the main application.
  # Notice: This method does *not* return the academic title of the user.
  # 
  # Here, title returns the name and the aktivitaetszahl, e.g. "Max Mustermann E10 H12".
  # 
  def title
    ( name + "  " + aktivitaetszahl ).strip if name && aktivitaetszahl
  end
  
  # This method returns the bv (Bezirksverband) the user is associated with.
  #
  def bv
    if Bv.all and self.ancestor_groups
      bv_of_this_user = ( Bv.all & self.ancestor_groups ).first
    end
    return bv_of_this_user.becomes Bv if bv_of_this_user
  end

  # This method returns the aktivitaetszahl of the user, e.g. "E10 H12".
  #
  def aktivitaetszahl
    self.corporations
      .sort_by { |corporation| corporation.membership_of(self).created_at } # order by date of joining
      .collect do |corporation| 
      if not self.guest_of? corporation
        year_of_joining = ""
        year_of_joining = corporation.membership_of( self ).created_at.to_s[2, 2] if corporation.membership_of( self ).created_at
        #corporation.token + "\u2009" + year_of_joining
        token = corporation.token; token ||= ""
        token + year_of_joining
      end
    end.join( " " )
  end

  # Fill-in default profile.
  #
  def fill_in_template_profile_information
    self.profile_fields.create(label: :personal_title, type: "ProfileFieldTypes::General")
    self.profile_fields.create(label: :cognomen, type: "ProfileFieldTypes::General")

    self.profile_fields.create(label: :home_address, type: "ProfileFieldTypes::Address")
    self.profile_fields.create(label: :work_or_study_address, type: "ProfileFieldTypes::Address")
    self.profile_fields.create(label: :phone, type: "ProfileFieldTypes::Phone")
    self.profile_fields.create(label: :mobile, type: "ProfileFieldTypes::Phone")
    self.profile_fields.create(label: :fax, type: "ProfileFieldTypes::Phone")
    self.profile_fields.create(label: :homepage, type: "ProfileFieldTypes::Homepage")

    self.profile_fields.create(label: :academic_degree, type: "ProfileFieldTypes::AcademicDegree")
    self.profile_fields.create(label: :study, type: "ProfileFieldTypes::Study")

    self.profile_fields.create(label: :professional_category, type: "ProfileFieldTypes::ProfessionalCategory")
    self.profile_fields.create(label: :occupational_area, type: "ProfileFieldTypes::ProfessionalCategory")
    self.profile_fields.create(label: :employment_status, type: "ProfileFieldTypes::ProfessionalCategory")

    self.profile_fields.create(label: :bank_account, type: "ProfileFieldTypes::BankAccount")

    self.wingolfsblaetter_abo = true
  end


  # Abo Wingolfsblätter
  # ==========================================================================================

  def wbl_group
    @wbl_page ||= Page.where(title: "Wingolfsblätter").first
    @wbl_group ||= @wbl_page.child_groups.where(name: "Abonnenten").first if @wbl_page
    return @wbl_group
  end
  private :wbl_group


  def wingolfsblaetter_abo 
    return true if wbl_group && self.member_of?(wbl_group)
    return false
  end
  def wingolfsblaetter_abo=(new_abo_status)
    if wbl_group
      if new_abo_status == true
        wbl_group.assign_user self unless self.member_of? wbl_group
      else
        wbl_group.unassign_user self if self.member_of? wbl_group
      end
    end
  end


end

