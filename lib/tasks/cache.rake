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
    :groups,
    :pages
  ]
  
  task :users => [:environment, :requirements, :print_info] do
    log.section "Benutzer-Caches"
    
    # Load classes before reading those objects from cache.
    Corporation
    Flag
    AddressLabel
    UserGroupMembership
    Bv
    
    User.find_each do |user|
      begin
        user.fill_cache

        print ".".green
      rescue => e
        print "F\n".red
        print "Error caching user #{user.id}: #{e.message}.\n".red
      end        
    end
    log.success "\nFertig."
  end
  
  task :memberships => [:environment, :requirements, :print_info] do
    log.section "Benutzer-Gruppen-Mitgliedschaften"
    
    User.find_each do |user|
      user.memberships.each do |membership|
        begin
          membership.fill_cache
        rescue => e
          print "F\n".red
          print "Error caching membership #{membership.id}: #{e.message}.\n".red
        end        
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
  
  task :pages => [:environment, :requirements, :print_info] do
    log.section "Inhaltsseiten"
    
    # Load classes before reading from cache.
    # ...
    
    Page.find_each do |page|
      begin
        page.fill_cache
      
        print ".".green
      rescue => e
        print "F\n".red
        print "Error caching page #{page.id}: #{e.message}.\n".red
      end
    end
    log.success "\nFertig."
  end
end