namespace :cache do

  task :requirements do
    require 'importers/models/log'
  end
  
  task :print_info => [:requirements] do
    log.head "Cache"
    log.info "Dieser Task erneuert abgelaufene Caches."
    log.info ""
  end
  
  task :all => [
    :environment, :requirements, :print_info,
    :users
  ]
  
  task :users do
    log.section "Benutzer-Caches"
    
    User.find_each do |user|
      user.cached_address_label
      user.cached_title
      user.cached_first_corporation
      user.cached_aktivitaetszahl
      user.cached_last_group_in_first_corporation
      
      print ".".green
    end
    log.success "\nFertig."
  end
end