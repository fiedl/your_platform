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
    #             user.handle_primary_corporation( user_data, progress )
    #             user.handle_current_corporations( user_data )
    #             user.handle_netenv_status( user_data.netenv_status )
    #             user.handle_former_corporations( user_data )
                user.perform_consistency_check_for_aktivitaetszahl( user_data )
    #             user.handle_deceased( user_data )
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

end

User.send( :include, UserImportMethods )

