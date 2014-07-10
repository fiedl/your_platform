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
    :members_postal_addresses
  ]
  
  task :members_postal_addresses do
    log.section "Post-Anschrift-Sammlungen von Gruppen-Mitgliedern (z.B. für Adress-Etiketten)"
    
    User.find_each do |user|
      user.cached_postal_address_with_name_surrounding
      print ".".green
    end
    log.success "\nFertig."
  end
end