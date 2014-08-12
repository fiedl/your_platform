# Run this file by `rake import:standard_workflows` to provide standard workflows for the
# Wah groups. The changes are only applied if the workflow is missing.
# Thus, it can be used to restore accidently deleted workflows.
#
# SF 2012-07-23

require 'importers/models/log'
require 'colored'

namespace :import do
  
  desc "Import standard workflows for corporations."
  task :workflows => [
    'environment',
    'bootstrap:all',
    'workflows:print_info',
    'workflows:import_workflows_for_wah_groups'
  ]
  
  namespace :workflows do
    
    task :print_info do
      log.section "Workflows importieren."
    end

    desc "Import Standard Workflows for Wah Groups"
    task import_workflows_for_wah_groups: :environment do
      STDOUT.sync = true
    
      require 'csv'
      file_name = File.join( Rails.root, "import", "workflows_for_standard_wah_structure.csv" )
      if File.exists? file_name
    
        wah_counter = 0
        workflow_counter = 0
    
        for corporation in Corporation.all   # [Corporation.find_by_token("H")]   # for testing
          old_workflow_counter = workflow_counter
    
          CSV.foreach file_name, headers: true, col_sep: ';' do |row|
    
            # csv headers:
            # workflow_name; workflow_belongs_to_group_names; remove_from_group_name; add_to_group_name
    
            workflow_name = row[ 'workflow_name' ].strip
            workflow_belongs_to_group_names = row[ 'workflow_belongs_to_group_names' ].strip
              .split( "," ).collect { |str| str.strip }
            remove_from_group_names = row[ 'remove_from_group_names' ].strip
              .split( "," ).collect { |str| str.strip }
            add_to_group_name = row[ 'add_to_group_name' ].strip
            workflow_description = row[ 'description' ].strip
            
            unless corporation.descendant_workflows.collect { |workflow| workflow.name }.include?(workflow_name)
    
              workflow_belongs_to_groups = workflow_belongs_to_group_names.collect do |group_name|
                group = corporation.descendant_groups.where(name: group_name).first
                log.warning "Gruppe #{group_name} in Corporation #{corporation.token} nicht gefunden. Bitte Workflow '#{workflow_name}' überprüfen!" unless group
                group
              end - [ nil ]
              workflow_belongs_to_groups << corporation if workflow_belongs_to_groups.count == 0
              remove_from_groups = remove_from_group_names.collect do |group_name|
                group = corporation.descendant_groups.where(name: group_name).first
                log.warning "Gruppe #{group_name} in Corporation #{corporation.token} nicht gefunden. Bitte Workflow '#{workflow_name}' überprüfen!" unless group
                group
              end - [ nil ]
              add_to_group = corporation.descendant_groups.where(name: add_to_group_name).first
              
              workflow_counter += 1
              w = Workflow.create name: workflow_name, description: workflow_description
              
              sequence_counter = 0
              remove_from_groups.collect do |group|
                sequence_counter += 1
                w.steps.create brick_name: "RemoveFromGroupBrick", parameters: {:group_id => group.id}, sequence_index: sequence_counter
              end
              sequence_counter += 1
              w.steps.create brick_name: "AddToGroupBrick", parameters: {:group_id => add_to_group.id}, sequence_index: sequence_counter
              sequence_counter += 1
              w.steps.create brick_name: "LastMembershipNeedsReviewBrick", sequence_index: sequence_counter
              
              for parent_group in workflow_belongs_to_groups
                w.parent_groups << parent_group
              end
              
            end
          end
    
          if old_workflow_counter < workflow_counter
            wah_counter += 1
            print ".".green # just as a kind of progress bar.
          else
            print ".".yellow
          end
    
        end
    
        print "\n"
        log.success "#{workflow_counter} Workflows für #{wah_counter} Corporations erstellt."
        log.success "#{Corporation.all.count - wah_counter} Corporations haben keine Änderung benötigt."
    
      end
    end
    
  end

end
