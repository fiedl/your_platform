require 'importers/models/log'

namespace :import do
  
  desc "Import all date from structure files and data files of the netenv system."
  task :all do

    tasks_to_execute = [ 
      'bootstrap:all',
      'import:corporations',
      'import:bvs',
      'import:external_corporations',
      'import:standard_workflows',
      'import:group_profiles',
      'import:users',
      'cache:users'
    ]

    
    $log = Log.new
    
    $log.head "Wingolfsplattform Import System"
    $log.info "Welcome. Please grab a beer and sit back."
    $log.info "This script will import everything for you."
    
    $log.section "Import files"
    $log.info "Import folder: " + File.join(Rails.root, "import/")
    $log.warning "Make sure the CSV files end with an empty line."
    
    $log.section "Agenda"
    display_agenda_for tasks_to_execute
    
    execute tasks_to_execute
    
    $log.section "Import Complete."
    $log.info "All import tasks executed. We are done."
    $log.info "Congratulations!"
    $log.info ""
    $log.info "You may now visit http://wingolfsplattform.org"
    $log.info "to see the result of your hard work!"
    $log.info ""
    
  end
    
  def display_agenda_for(tasks_to_execute)
    system("bundle exec rake -T > /tmp/rake_toc")
    tasks_to_execute.each do |task_to_execute|
      system("cat /tmp/rake_toc |grep #{task_to_execute}")
    end
  end
  
  def execute(tasks_to_execute)
    tasks_to_execute.each do |task_to_execute|
      Rake::Task[task_to_execute].invoke
    end
  end
  
end
