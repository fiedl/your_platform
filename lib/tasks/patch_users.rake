namespace :patch do

  task :users => [
    'environment',
    'requirements',
    'users:print_info',
    'users:reimport_ef_corporation_memberships',
    'users:hide_non_wingolfits',
    'users:remove_activities_without_wv_or_phv_membership'
#    'users:user_cannot_be_aktiver_and_philister_at_the_same_time'
  ]
  
  namespace :users do
    
    task :requirements do
      require 'importers/models/log'
      require 'importers/importer'
      require 'importers/models/netenv_user'
      require 'importers/models/user'
      require 'importers/models/string'
    end
        
    task :print_info do
      log.head "User Patcher"
      log.info "Dieser Task führt Korrekturen durch, die nach einem abgeschlossenen 'rake import:users' notwendig sind."
      log.info "Trello: https://trello.com/c/KI457uFK/540-import-patches"
      log.info ""
    end
    
    task :user_cannot_be_aktiver_and_philister_at_the_same_time => [:environment, :requirements] do
      log.section "Zeitgleich Aktiver und Philister"
      log.info "Ein Benutzer kann nicht gleichzeitig Aktiver und Philister sein."
      log.info "Betroffene Fälle:"
      
      User.find_each do |user|
        if user.wingolfit? and user.aktiver? and user.philister?
          log.info user.w_nummer
        end
      end
      
      # p NetenvUser.find_by_w_nummer( "W64742" ).corporations
      
    end
    
    task :hide_non_wingolfits => [:environment, :requirements] do
      log.section "Nicht-Wingolfiten verstecken"
      log.info "Alle Benutzer, die keine Wingolfiten sind, sollen als versteckt markiert werden,"
      log.info "damit sie nur von Administratoren gesehen werden können."
      log.info ""
      log.info "Im Moment versteckte Benutzer: #{Group.hidden_users.members.count}"
      log.info ""
      log.info "Korrigiere Benutzer:"
      
      User.find_each do |user|
        if (not user.wingolfit?) and (not user.hidden?)
          user.hidden = true
          log.info "#{user.title} (#{user.w_nummer})"
        end
      end

      log.info ""
      log.info "Nach der Korrektur versteckte Benutzer: #{Group.hidden_users.members.count}"
    end
    
    task :delete_users_without_ldap_assignments => [:environment, :requirements] do
      log.section "Benutzer ohne LDAP-Zuordnung löschen."
      log.info "Benutzer ohne LDAP-Zuordnung werden in Netenv als gelöscht betrachtet,"
      log.info "ohne dabei gesondert als gelöscht markiert zu sein."
      log.info "Daher muss für alle Netenv-Benutzer ohne LDAP-Zuordnung sichergestellt"
      log.info "werden, dass sie im neuen System nicht vorhanden sind."
      log.info ""
      log.info "Gelöschte Benutzer:"
      
      NetenvUser.find_each do |netenv_user|
        if (netenv_user.ldap_assignments.count == 0) and (not netenv_user.deleted?)
          user = User.find_by_w_nummer(netenv_user.w_nummer)
          if user
            user.destroy
            log.info "#{netenv_user.name} (ehemals #{netenv_user.w_nummer})"
          end
        end
      end
    end
    
    task :remove_activities_without_wv_or_phv_membership => [:environment, :requirements] do
      log.section "Korporationsmitgliedschaften entfernen, wenn nicht mehr in WV oder PhV Mitglied."
      log.info "Es gibt Benutzer (z.B. W54613), deren Aktivitätszahl nicht aktualisiert wurde,"
      log.info "als die Mitgliedschaft endete. Dank der Aktivitätszahl wurden sie aber wieder"
      log.info "in die entsprechenden Korporationen importiert, was nun korrigiert werden muss."
      log.info ""
      log.info "Korrigierte Benutzer:"

      User.find_each do |user|
        if user.aktivitätszahl.present?
          for corporation in user.corporations
            if (not corporation.token.include? "!") and # keine Schweizer, da für diese keine LDAP-Gruppen existieren
              not (user.guest_of?(corporation)) and 
              not (user.former_member_of_corporation?(corporation)) and
              (user.netenv_user.ldap_assignments_in(corporation).count == 0)

              log.info "#{user.title} (#{user.w_nummer})"
              
              # TODO
            end
          end
        end
      end
      
    end
    
    task :reimport_ef_corporation_memberships => [:environment, :requirements] do
      log.section "Re-Import der Erfurter Aktiven"
      log.info "Da Erfurt (Ef) im Netenv-LDAP als 'Erf' kodiert war, ist hier ein erneuter Import"
      log.info "der UserGroupMemberships der Korporationen der Erfurter Aktiven von Nöten,"
      log.info "um ihren aktuellen Aktivenstatus korrekt in das neue System zu übertragen."
      log.info ""
      log.info "Korrigierte Benutzer:"
      
      users = Corporation.find_by_token("Ef").aktivitas.members.to_a
      # users = [ User.find_by_w_nummer("W52386") ]
      
      users.each do |user|
        user.import_corporation_memberships_from user.netenv_user
        log.info "#{user.title} (#{user.w_nummer})"
      end
    end
    
  end
  
  def log
    $log ||= Log.new
  end
  
end

