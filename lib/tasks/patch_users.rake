namespace :patch do

  task :users => [
    'environment',
    'users:print_info',
    'users:test'
  ]
  
  namespace :users do
    
    require 'importers/models/log'
    require 'importers/importer'
    require 'importers/models/netenv_user'
        
    task :print_info do
      $log = Log.new
      $log.head "User Patcher"
      $log.info "This fixes import issues after the original import 'rake import:users' has run."
      $log.info "Trello: https://trello.com/c/KI457uFK/540-import-patches"
      $log.info ""
    end
    
    task :test do
      
      p NetenvUser.find_by_w_nummer( "W64742" ).corporations
      
    end
    
  end
  
end