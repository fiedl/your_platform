namespace :patch do

  #
  task :workflows => [
    'workflows:part1'
  ]
  
  namespace :workflows do
    
    task :requirements do
      require 'importers/models/log'
    end
        
    task :print_info => [:requirements] do
      log.head "Workflow Patcher"
      log.info "Dieser Patch führt Korrekturen an den bereits importierten Workflows durch."
      log.info ""
    end
    
    task :part1 => [
      'environment',
      'requirements',
      'print_info',
      'add_bv_assignment_to_philistration'
    ]
    
    task :add_bv_assignment_to_philistration => [:environment, :requirements, :print_info] do
      log.section "BV-Zuordnung zum Philistrations-Workflow hinzufügen."
      log.info "Nach Philistration soll automatisch eine BV-Zuordnung durchgeführt werden."
      log.info ""
      
      workflows = Workflow.where(name: "Philistration")
      counter = 0
      for workflow in workflows
        last_step = workflow.steps.order(:sequence_index).last

        new_step = workflow.steps.build
        new_step.sequence_index = last_step.sequence_index + 1
        new_step.brick_name = "AutoAssignBvBrick"
        new_step.save
        
        counter += 1
        print ".".green
      end
      
      print "\n"
      log.info ""
      log.success "#{counter} Workflows modified."
    end

  end
  
  def log
    $log ||= Log.new
  end
  
end

