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
    :address_labels
  ]
  
  task :address_labels do
    log.section "Adress-Etiketten der Post-Anschriften"
    
    User.find_each do |user|
      user.cached_address_label
      print ".".green
    end
    log.success "\nFertig."
  end
end