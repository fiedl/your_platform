# Nach dem Import der Benutzer sind einige Patches erforderlich, um fehlerhafte Daten
# in der Netenv-Datenbank zu korrigieren.
#
# Siehe Trello: https://trello.com/c/KI457uFK/540-import-patches
#
namespace :patch do

  #
  task :users => [
    'users:part1',
    'users:part2',
    'users:part3'
  ]
  
  namespace :users do
    
    task :requirements do
      require 'importers/models/log'
      require 'importers/importer'
      require 'importers/models/netenv_user'
      require 'importers/models/user'
      require 'importers/models/string'
    end
        
    task :print_info => [:requirements] do
      log.head "User Patcher"
      log.info "Dieser Task führt Korrekturen durch, die nach einem abgeschlossenen"
      log.info "'rake import:users' notwendig sind."
      log.info ""
      log.info "Trello: https://trello.com/c/KI457uFK/540-import-patches"
      log.info ""
    end
    
    task :part1 => [                                       # Beachtung der Reihenfolge wichtig!
      'environment',                                       # Nummerierung gemäß der Kommentare in Trello:
      'requirements',                                      # https://trello.com/c/KI457uFK/540-import-patches
      'print_info',                                        #
      'fix:officers',                                      #    (6) Amtsträger-Gruppen
      'reimport_ef_corporation_memberships',               #    (3) Ef-Aktive erneut importieren
      'delete_users_without_ldap_assignments',             #    (4) Benutzer ohne LDAP-String löschen
      'hide_non_wingolfits',                               #    (1) Nicht-Wingolfiten verstecken
      'subsequent_philistrations',                         #    (5) Philistrationen nachreichen
      'find_users_with_missing_wv_or_phv_membership'       #    (2) Auf weitere Inkonsistenzen überprüfen
    ]
    
    task :part2 => [
      'environment',
      'requirements',
      'print_info',
      'remove_ehrenphilistres_from_regular_philister_groups', # (7) Ehrenphilister. Beispiel: W65507
      'make_sft_and_nstft_memberships_continue'               # (8) Stifter und Neustifter
    ]
    
    task :part3 => [
      'environment',
      'requirements',
      'print_info',
      'subsequent_philistrations_for_partly_exited_members'   # (9) Philistration für teilw. Ausgetr. nachreichen
    ]
    
    task :remove_ehrenphilistres_from_regular_philister_groups => [:environment, :requirements, :print_info] do
      log.section "Ehrenphilister aus den Gruppen der regulären Philister entfernen."
      log.info "Man kann nicht Ehrenphilister und regularärer Philister gleichzeitig sein."
      log.info "Insbesondere kann man nicht gleichzeitig Philister und Ehrenphilister in"
      log.info "der gleichen Verbindung sein, was aber im Datenstand der Fall sein kann,"
      log.info "da im Netenv-LDAP-String nicht unterschieden wurde zwischen Phil und Eph."
      log.info ""
      
      total_num_of_ehrenphilistres = Group.where(name: "Ehrenphilister").collect { |group| group.child_users }.flatten.uniq.count
      total_num_of_current_ehrenphilistres = Group.where(name: "Ehrenphilister").collect { |group| group.members }.flatten.uniq.count
      
      log.info "Zur Zeit sind #{total_num_of_ehrenphilistres} Ehrenphilister im System eingetragen."
      log.info "Davon haben #{total_num_of_current_ehrenphilistres} diesen Status aktuell inne."
      log.info ""
      log.info "Korrigierte Benutzer:"

      ehrenphilistres = Group.where(name: "Ehrenphilister").collect { |group| group.child_users }.flatten
      
      counter = 0
      for user in ehrenphilistres
        for corporation in user.corporations
          eph_group = corporation.status_group("Ehrenphilister")
          phil_group = corporation.status_group("Philister")
          if user.in? phil_group.child_users
            eph_membership = UserGroupMembership.now_and_in_the_past.find_by_user_and_group(user, eph_group)
            phil_membership = UserGroupMembership.now_and_in_the_past.find_by_user_and_group(user, phil_group)
            
            if eph_membership
              eph_membership.update_attribute :valid_to, phil_membership.valid_to
              phil_membership.destroy

              counter += 1
              log.info "#{user.title} (#{user.w_nummer})  [#{corporation.token}]"
            elsif not eph_membership
              # Nach Bundessatzung muss das Ehren-Band das erste Band sein. Bahndaufnahme 
              # regulärer Bänder ist möglich.
              # 
              if corporation == user.corporations.first
                log.warning "Der folgende Benutzer bedarf händischer Kontrolle."
                log.warning "    Das Ehren-Band muss nach Bundessatzung das erste Band sein."
                log.warning " >  #{user.title} (#{user.w_nummer})  [#{corporation.token}]"
              end
            end
          end
        end
      end
      
      log.success "Es wurden #{counter} Mitgliedschaften korrigiert."
      log.info ""

      total_num_of_ehrenphilistres = Group.where(name: "Ehrenphilister").collect { |group| group.child_users }.flatten.uniq.count
      total_num_of_current_ehrenphilistres = Group.where(name: "Ehrenphilister").collect { |group| group.members }.flatten.uniq.count
      log.info "Zur Zeit sind #{total_num_of_ehrenphilistres} Ehrenphilister im System eingetragen."
      log.info "Davon haben #{total_num_of_current_ehrenphilistres} diesen Status aktuell inne."
      log.info ""
    end
    
    task :make_sft_and_nstft_memberships_continue => [:environment, :requirements, :print_info] do
      log.section "Sft- und Nstft-Mitgliedschaften nicht enden lassen."
      log.info "Stifter und Neustifter sollen in den entsprechenden Gruppen immer eingesehen"
      log.info "werden können. Sie sollen also nicht aus den Gruppen ausgetragen werden, sobald"
      log.info "sie sterben. Beim Import wurden sie bereits ausgetragen, was korrigiert werden muss."
      log.info ""
      log.info "Betroffene Benutzer:"
      
      groups = Group.where(name: ["Stifter", "Neustifter"])
      membership_links = groups.collect { |group| group.links_as_parent_for_users }.flatten
      
      counter = 0
      for membership_link in membership_links
        membership = membership_link.becomes UserGroupMembership
        if membership.valid_to
          membership.update_attribute(:valid_to, nil)

          counter += 1
          log.info "#{membership.user.title} (#{membership.user.w_nummer})  [#{membership.group.corporation.token}]"
        end
      end
      
      log.success "Es wurden #{counter} Mitgliedschaften korrigiert."
    end
    
    task :subsequent_philistrations => [:environment, :requirements, :print_info] do
      log.section "Philistrationen nachreichen."
      log.info "Ein Benutzer kann idR. nicht gleichzeitig Aktiver und Philister sein. Bei solchen Benutzern"
      log.info "ist wahrscheinlich die Information über die Philistration verloren gegangen."
      log.info "Die Korporations-Mitgliedschaften dieser Benutzer müssen (mit dem verbsserten"
      log.info "Import-System) neu importiert werden."
      log.info ""
      log.info "Betroffene Fälle:"
      
      User.find_each do |user|
        if user.wingolfit? and user.aktiver? and user.philister?
          user.import_corporation_memberships_from user.netenv_user
          log.info "#{user.title} (#{user.w_nummer})"
        end
      end
    end
    
    task :subsequent_philistrations_for_partly_exited_members => [:environment, :requirements, :print_info] do
      log.section "Philistrationen nachreichen für teilweise Ausgetretene."
      log.info "Für Benutzer, die aus allen Verbindungen, in denen sie bereits Philister waren,"
      log.info "ausgetreten waren, hat der vorige Mechanismus zum Nachreichen von Philistrationen"
      log.info "nicht funktioniert, was hiermit korrigiert wird."
      log.info ""
      
      # Beispiel zum Testen: W51687
      
      alle_aktiven = Group.where(name: "Aktivitas").collect { |aktivitas| aktivitas.members }.flatten.uniq
      log.info "Zur Zeit sind im Wingolf #{alle_aktiven.count} Aktive gemeldet."
      
      aktive_und_gleichzeitig_philister = alle_aktiven.select { |user| user.parent_groups.collect { |group| group.name }.include? "Philister" }
      log.info "Davon sind #{aktive_und_gleichzeitig_philister.count} gleichzeitig als Philister eingetragen."
      log.info ""
      
      log.info "Korrigierte Benutzer:"
      
      for user in aktive_und_gleichzeitig_philister
        user.import_corporation_memberships_from user.netenv_user
        log.info "#{user.title} (#{user.w_nummer})"
      end

      log.info ""
      log.success "Fertig."
      log.info ""

      alle_aktiven = Group.where(name: "Aktivitas").collect { |aktivitas| aktivitas.members }.flatten.uniq
      log.info "Zur Zeit sind im Wingolf #{alle_aktiven.count} Aktive gemeldet."
      aktive_und_gleichzeitig_philister = alle_aktiven.select { |user| user.parent_groups.collect { |group| group.name }.include? "Philister" }
      log.info "Davon sind #{aktive_und_gleichzeitig_philister.count} gleichzeitig als Philister eingetragen."
    end
    
    task :hide_non_wingolfits => [:environment, :requirements, :print_info] do
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
    
    task :delete_users_without_ldap_assignments => [:environment, :requirements, :print_info] do
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
    
    task :find_users_with_missing_wv_or_phv_membership => [:environment, :requirements, :print_info] do
      log.section "Inkonsistenzen suchen: Benutzer mit fehlender WV- oder PhV-Mitgliedschaft."
      log.info "Es gibt Benutzer (z.B. W54613), deren Aktivitätszahl nicht aktualisiert wurde,"
      log.info "als die Mitgliedschaft endete. Dank der Aktivitätszahl wurden sie aber wieder"
      log.info "in die entsprechenden Korporationen importiert, was nun korrigiert werden muss."
      log.info ""
      log.info "Da der Zustand nicht eindeutig rekonstruierbar ist, ist hier manuelle Eingabe"
      log.info "erforderlich. Einige Benutzer wurden bereits überprüft. Bitte Ergebnisse von"
      log.info "https://trello.com/c/KI457uFK/540-import-patches vergleichen."
      log.info ""
      log.warning "Möglicher Handlungsbedarf bei:"
      log.warning ""

      User.find_each do |user|
        if user.aktivitätszahl.present?
          for corporation in user.corporations
            if (not corporation.token.include? "!") and # keine Schweizer, da für diese keine LDAP-Gruppen existieren
              not (user.guest_of?(corporation)) and 
              not (user.former_member_of_corporation?(corporation)) and
              (user.alive?) and
              (user.netenv_user.ldap_assignments_in(corporation).count == 0)

              log.warning "#{user.title} (#{user.w_nummer})"
            end
          end
        end
      end
      
    end
    
    task :reimport_ef_corporation_memberships => [:environment, :requirements, :print_info] do
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

