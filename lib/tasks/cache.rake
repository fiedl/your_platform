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
    :users,
    :memberships, 
    :groups
  ]
  
  task :users => [:environment, :requirements, :print_info] do
    log.section "Benutzer-Caches"
    
    # Load classes before reading those objects from cache.
    Corporation
    Flag
    AddressLabel
    UserGroupMembership
    
    User.find_each do |user|
      user.fill_cache

      print ".".green
    end
    log.success "\nFertig."
  end
  
  task :memberships => [:environment, :requirements, :print_info] do
    log.section "Benutzer-Gruppen-Mitgliedschaften"
    
    User.find_each do |user|
      user.memberships.each do |membership|
        membership.fill_cache
      end
      
      print ".".green
    end
    log.success "\nFertig."
  end
  
  task :groups => [:environment, :requirements, :print_info] do
    log.section "Gruppen"
    
    # Load classes before reading from cache.
    User
    Page
    NavNode
    Corporation
    
    Group.find_each do |group|
      begin
        group.fill_cache
      
        print ".".green
      rescue => e
        print "F\n".red
        print "Error caching group #{group.id}: #{e.message}.\n".red
      end
    end
    log.success "\nFertig."
  end
end