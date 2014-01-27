namespace :cache do

  desc "For all users call the cached methods to load the value in the cache"
  task :users => [:environment] do
    require 'colored'
    require 'importers/models/log'
    
    log = Log.new
    log.section "Cache User attributes."
    
    log.info "For all users call the cached methods to load the value in the cache."
    log.info "There are #{User.count} users in total now."

    User.all.each do |user|
      user.cached_aktivitaetszahl
      user.cached_last_group_in_first_corporation
      print ".".green
    end
    
    print "\n"
    log.info "Finished caching."
   
  end
end
