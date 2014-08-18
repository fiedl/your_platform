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
      user.cached_address_label
      user.cached_title
      user.cached_first_corporation
      user.cached_aktivitaetszahl
      user.cached_last_group_in_first_corporation
      user.cached_date_of_birth
      user.cached_bv
      
      print ".".green
    end
    log.success "\nFertig."
  end
  
  task :memberships => [:environment, :requirements, :print_info] do
    log.section "Benutzer-Gruppen-Mitgliedschaften"
    
    User.find_each do |user|
      user.memberships.each do |membership|
        membership.cached_valid_from
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
        group.cached_find_admins
        group.cached_officers_of_self_and_parent_groups
        group.cached_corporation
        group.cached_leaf_groups
        group.cached_memberships
        group.cached_latest_memberships
        group.cached_memberships_this_year
      
        print ".".green
      rescue => e
        print "F\n".red
        print "Error caching group #{group.id}: #{e.message}.\n".red
      end
    end
    log.success "\nFertig."
  end
end