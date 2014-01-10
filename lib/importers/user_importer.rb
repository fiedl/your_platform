require 'importers/importer'
require 'importers/models/user'
require 'importers/models/profile_field'
require 'importers/models/netenv_user'

class UserImporter < Importer
  
  def initialize( args = {} )
    super(args)
    @object_class_name = "User"
  end
  
  def import
    log.head "Wingolfsplattform User Import"
    
    log.section "Import Parameters"
    log.info "Import file:   #{@filename}"
    log.info "Import filter: #{@filter || 'none'}"
    
    log.section "Progress"
    log.info ". = successfully created, u = successfully updated, I = ignored, W = warning, F = failure"
    
    import_file = ImportFile.new( filename: @filename, data_class_name: "NetenvUser" )
    import_file.each_row do |netenv_user|
      
      # Benutzer, die dem Import-Filter nicht entsprechen, werden übergangen.
      # Der Import-Filter wird beim Aufruf des Imports in lib/tasks/import_users.rake
      # gesetzt.
      #
      next unless netenv_user.match? @filter
      
      # Test-Benutzer des bisherigen Betreibers werden ignoriert.
      # 
      next if dummy_user? netenv_user
      
      # Benutzer, die in der Datenbank des bisherigen Betreibers als gelöscht markiert
      # sind, wurden versehentlich angelegt. Ihre Daten werden nicht importiert.
      #
      next if deleted_user? netenv_user
      
      # Falls die E-Mail-Adresse bereits im neuen System vergeben ist, und zwar einem
      # anderen Benutzer, liegt hier vermutlich ein Fehler vor. Deswegen wird eine Warnung
      # angezeigt. Der vorhandene Benutzer behält seine E-Mail-Adresse. Der zweite Benutzer
      # wird zwar angelegt, aber ohne E-Mail-Adresse.
      # 
      netenv_user.do_not_import_primary_email if email_duplicate? netenv_user
      
      # Existierenden Benutzer des neuen Systems heraussuchen oder einen neuen Benutzer
      # anlegen, falls noch keiner existiert.
      # 
      updating_user = find_existing_user_for(netenv_user) ? true : false
      user = find_or_build_user_for netenv_user
      
      # Grundlegende Attribute übernehmen.
      # Vor- und Zuname, E-Mail-Adresse, W-Nummer, Geburtsdatum.
      # 
      user.import_basic_attributes_from netenv_user
      user.save
      
      # Profilfelder importieren.
      # 
      user.import_general_profile_fields_from netenv_user
      user.import_contact_profile_fields_from netenv_user
      user.import_study_profile_fields_from netenv_user
      user.import_professional_profile_fields_from netenv_user
      user.import_bank_profile_fields_from netenv_user
      user.import_communication_profile_fields_from netenv_user
      
      # Mitgliedschaften in Korporationen importieren.
      # 
      user.import_corporation_memberships_from netenv_user

      # Zeitstempel des Datensatzes importieren.
      # created_at, updated_at.
      #
      user.import_timestamps_from netenv_user
      
      # Fortschritt festhalten. In Abhängigkeit davon, ob ein neuer Benutzer angelegt oder
      # ein vorhandener aktualisiert wurde, wird ein entsprechendes Symbol angezeigt.
      #
      progress.log_success(updating_user)
    end

    log.info ""
    log.section "Results"    
    progress.print_status_report
  end
  
  def dummy_user?(netenv_user)
    if netenv_user.dummy_user?
      warning = { message: "Ignoring dummy user #{netenv_user.w_nummer}.",
        w_nummer: netenv_user.w_nummer, name: netenv_user.name,
        netenv_aktivitätszahl: netenv_user.netenv_aktivitätszahl
      }
      progress.log_ignore(warning)
      return true
    end
  end
  
  def deleted_user?(netenv_user)
    if netenv_user.deleted?
      warning = { message: "Ignoring deleted user #{netenv_user.w_nummer}.",
                  w_nummer: netenv_user.w_nummer, name: netenv_user.name }
      progress.log_ignore(warning)
      return true
    end
  end
  
  def email_duplicate?(netenv_user)
    return false unless netenv_user.email.present?

    existing_user_with_this_email = User.find_by_email(netenv_user.email)
    return false unless existing_user_with_this_email

    if existing_user_with_this_email.w_nummer != netenv_user.w_nummer
      warning = { message: "Email #{netenv_user.email} duplicate. The user #{existing_user_with_this_email.w_nummer} was here first. The user #{netenv_user.w_nummer} is imported, but WITHOUT EMAIL ADDRESS.",
        w_nummer: netenv_user.w_nummer, name: netenv_user.name, email: netenv_user.email,
        existing_user: existing_user_with_this_email.w_nummer, existing_user_name: existing_user_with_this_email.name 
      }
      progress.log_warning(warning)
      return true
    end
  end
  
  def find_or_build_user_for(netenv_user)
    find_existing_user_for(netenv_user) || User.new
  end
  
  def find_existing_user_for(netenv_user)
    User.find_by_w_nummer(netenv_user.w_nummer)
  end
  
end
