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
    Group.find_each do |group|
      if (group.members.count > 10) and 
          (group.id > 1) and # for security reasons, do not cache the :everyone group.
          (group.child_groups.count < 15) # no super groups (Corporations, BVs, etc.)
        
        group.cached_members_postal_addresses
        print ".".green
      else
        print "."
      end
    end
    log.success "\nFertig."
  end
end