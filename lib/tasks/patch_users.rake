namespace :patch do

  task :users => [
    'environment',
    'users:print_info',
    'users:hide_non_wingolfits'
#    'users:user_cannot_be_aktiver_and_philister_at_the_same_time'
  ]
  
  namespace :users do
    
    require 'importers/models/log'
    require 'importers/importer'
    require 'importers/models/netenv_user'
        
    task :print_info do
      $log = Log.new
      $log.head "User Patcher"
      $log.info "Dieser Task führt Korrekturen durch, die nach einem abgeschlossenen 'rake import:users' notwendig sind."
      $log.info "Trello: https://trello.com/c/KI457uFK/540-import-patches"
      $log.info ""
    end
    
    task :user_cannot_be_aktiver_and_philister_at_the_same_time do
      
      $log.section "Zeitgleich Aktiver und Philister"
      $log.info "Ein Benutzer kann nicht gleichzeitig Aktiver und Philister sein."
      $log.info "Betroffene Fälle:"
      
      User.find_each do |user|
        if user.wingolfit? and user.aktiver? and user.philister?
          $log.info user.w_nummer
        end
      end
      
      # p NetenvUser.find_by_w_nummer( "W64742" ).corporations
      
    end
    
    task :hide_non_wingolfits do
      $log.section "Nicht-Wingolfiten verstecken"
      $log.info "Alle Benutzer, die keine Wingolfiten sind, sollen als versteckt markiert werden,"
      $log.info "damit sie nur von Administratoren gesehen werden können."
      $log.info ""
      $log.info "Im Moment versteckte Benutzer: #{Group.hidden_users.members.count}"
      $log.info ""
      $log.info "Korrigiere Benutzer:"
      
      User.find_each do |user|
        if (not user.wingolfit?) and (not user.hidden?)
          user.hidden = true
          $log.info "#{user.title} (#{user.w_nummer})"
        end
      end

      $log.info ""
      $log.info "Nach der Korrektur versteckte Benutzer: #{Group.hidden_users.members.count}"
      
    end
    
  end
  
end