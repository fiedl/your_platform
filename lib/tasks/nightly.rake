namespace :nightly do
  require 'importers/models/log'
  
  # This task is run by a cron job every night.
  #
  task :all => [
    :print_info,
    :cache,
    :print_info_finish
  ]
  
  task :print_info => [:environment] do
    log.head "Nächtliche Aufgaben: #{I18n.localize(Time.zone.now)}"
  end
  task :print_info_finish => [:environment] do
    log.head "Nächtliche Aufgaben"
    log.success "Abgeschlossen: #{I18n.localize(Time.zone.now)}"
  end
  task :cache => ['cache:all']

end