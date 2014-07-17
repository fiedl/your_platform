namespace :nightly do

  # This task is run by a cron job every night.
  #
  task :all => [
    :cache
  ]
  
  task :cache => ['cache:all']

end