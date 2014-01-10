# -*- coding: utf-8 -*-
require 'importers/importer'

#
# This file contains the code to import users from the netenv csv export.
# Import users like this:
#
#   require 'importers/user_import'
#   importer = UserImporter.new( file_name: "path/to/csv/file", filter: { "uid" => "W51061" },
#                                update_policy: :update )
#   importer.import
#   User.all  # will list all users
#
class UserImporter < Importer

  def import
    # import_file = ImportFile.new( file_name: @file_name, data_class_name: "UserData" )
    # import_file.each_row do |user_data|
    #   if user_data.match?(@filter) 
    #     handle_dummies(user_data) do
    #       handle_deleted(user_data) do
    #         handle_existing(user_data) do |user|
    #           handle_existing_email(user_data) do |email_warning|
    #             p user_data.uid
    #             user.update_attributes( user_data.attributes )
    #             user.save
    #             user.import_profile_fields( user_data.profile_fields_array, update_policy)
    #             user.reset_memberships_in_corporations
                user.handle_primary_corporation( user_data, progress )
                user.handle_current_corporations( user_data )
                user.handle_netenv_status( user_data.netenv_status )
                user.handle_former_corporations( user_data )
                user.perform_consistency_check_for_aktivitaetszahl( user_data )
                user.handle_deceased( user_data )
                user.assign_to_groups( user_data.groups )
                progress.log_success unless email_warning
              end
            end
          end
        end
      end
    end
    progress.print_status_report
  end

end

class UserData < ImportDataset

  
  # TODO: WO EINFÜGEN?
  def contact_name
    
  end


  def groups
    ldap_group_string = d('epddynagroups') 
    ldap_group_string += "|" + d('epddynagroupsstatus') if d('epddynagroupsstatus')
    ldap_assignments = ldap_group_string.split("|")
    ldap_group_paths = []
    ldap_assignments.each do |assignment| # assignment = "o=asd,ou=def"
      ldap_group_path = []
      ldap_category_assignments = assignment.split(",")
      ldap_category_assignments.each do |category_assignment|
        ldap_category, ldap_group = category_assignment.split("=")
        #ldap_group_path << { ldap_category => ldap_group }
        ldap_group_path << ldap_group
      end
      ldap_group_paths << ldap_group_path
    end
    ldap_group_paths
  end

end



module UserImportMethods

  def assign_to_groups( groups )
    p "TODO: GROUP ASSIGNMENT"
    #p groups
    #p "-----"
  end

  def handle_netenv_status( status )
    self.hidden = true if status == :silent
    if status == :deleted
      raise 'trying to handle deleted user, but all deleted users should have been filtered out.' 
    end
  end

  def handle_deceased( user_data )
    if user_data.deceased?
      if self.corporations.count == 0
        raise 'the user has no corporations, yet. please handle_deceased after assigning the user to corporations.'
      end
      self.corporations.each do |corporation|
        group_to_assign = corporation.child_groups.find_by_flag(:deceased_parent)
        group_to_assign.assign_user self, joined_at: user_data.netenv_org_membership_end_date
      end
    end
  end

  def handle_primary_corporation( user_data, progress )
    corporation = user_data.corporations.first
    
    # Aktivmeldung
    raise 'aktivmeldungsdatum not given' if not user_data.aktivmeldungsdatum
    hospitanten = corporation.descendant_groups.find_by_name("Hospitanten")
    membership_hospitant = hospitanten.assign_user self, joined_at: user_data.aktivmeldungsdatum
    
    # Reception
    if user_data.receptionsdatum
      if (user_data.philistrationsdatum) and (user_data.receptionsdatum > user_data.philistrationsdatum)
        warning = { message: 'inconsistent netenv data: philistration before reception! ingoring reception.',
                    name: self.name, uid: user_data.w_nummer, 
                    philistrationsdatum: user_data.philistrationsdatum,
                    receptionsdatum: user_data.receptionsdatum }
        progress.log_warning(warning)
      else
        krassfuxen = corporation.descendant_groups.find_by_name("Kraßfuxen")
        membership_krassfux = membership_hospitant.promote_to krassfuxen, date: user_data.receptionsdatum
      end
    end
    
    # Burschung
    if user_data.burschungsdatum
      burschen = corporation.descendant_groups.find_by_name("Aktive Burschen")
      membership_burschen = self.reload.current_status_membership_in(corporation)
        .promote_to burschen, date: user_data.burschungsdatum
    end
    
    # Philistration
    if user_data.philistrationsdatum
      philister = corporation.descendant_groups.find_by_name("Philister")
      membership_philister = self.reload.current_status_membership_in(corporation)
        .promote_to philister, date: user_data.philistrationsdatum
    end
  end

  def handle_current_corporations( user_data )
    user_data.current_corporations.each do |corporation|
      year_of_joining = user_data.year_of_joining(corporation)
      group_to_assign = nil
      if user_data.aktivmeldungsdatum.year.to_s == year_of_joining
        # Already handled by #handle_primary_corporation.
      else
        date_of_joining = year_of_joining.to_datetime
        if user_data.bandaufnahme_als_aktiver?( corporation )
          group_to_assign = corporation.descendant_groups.find_by_name("Aktive Burschen")
        elsif user_data.bandverleihung_als_philister?( corporation )
          group_to_assign = corporation.descendant_groups.find_by_name("Philister")
        end
        
        if user_data.ehrenphilister?(corporation)
          group_to_assign = corporation.descendant_groups.find_by_name("Ehrenphilister")
        end

        raise 'could not identify group to assign this user' if not group_to_assign
        group_to_assign.assign_user self, joined_at: date_of_joining
        
        if user_data.stifter?(corporation)
          corporation.descendant_groups.find_by_name("Stifter").assign_user self, joined_at: date_of_joining
        end
        if user_data.neustifter?(corporation)
          corporation.descendant_groups.find_by_name("Neustifter").assign_user self, joined_at: date_of_joining
        end
        
      end
    end
  end
  

  def perform_consistency_check_for_aktivitaetszahl( user_data )
    if user_data.aktivitaetszahl.to_s != self.reload.aktivitaetszahl.to_s
      raise "consistency check failed: aktivitaetszahl '#{user_data.aktivitaetszahl}' not reconstructed properly.
        The reconstructed one is '#{self.aktivitaetszahl}'."
    end
  end

  def handle_former_corporations( user_data )
    user_data.former_corporations.each do |corporation|
      reason = user_data.reason_for_exit(corporation)
      date = user_data.date_of_exit(corporation)
      former_members_parent_group = corporation.child_groups.find_by_flag(:former_members_parent)
      if reason == "ausgetreten"
        group_to_assign = former_members_parent_group.child_groups.find_by_name("Schlicht Ausgetretene")
      elsif reason == "gestrichen"
        group_to_assign = former_members_parent_group.child_groups.find_by_name("Gestrichene")
      end
      
      # Remove user from previous status groups of this corporation.
      (self.status_groups & corporation.status_groups).each do |status_group|
        status_group.unassign_user self
      end
      
      group_to_assign.assign_user self, joined_at: date
    end
  end

end

User.send( :include, UserImportMethods )

