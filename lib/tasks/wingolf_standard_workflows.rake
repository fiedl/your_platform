# Run this file by `rake wingolf_standard_workflows` to provide standard workflows for the 
# Wah groups. The changes are only applied for groups without workflows.
# Thus, it can be used to restore accidently deleted workflows.
#
# SF 2012-07-23

namespace :wingolf_standard_workflows do

  desc "Import Standard Workflows for Wah Groups" 
  task import_standard_workflows_for_wah_groups: :environment do
    STDOUT.sync = true
    p "Task: Import Standard Workflows for Wah Groups"
    
    require 'csv'
    file_name = File.join( Rails.root, "import", "workflows_for_standard_wah_structure.csv" )
    if File.exists? file_name

      wah_counter = 0
      workflow_counter = 0

      for wah in Wah.all 
        old_workflow_counter = workflow_counter
        
        CSV.foreach file_name, headers: true, col_sep: ';' do |row|
          
          # headers:
          # workflow_name; workflow_belongs_to_group_names; remove_from_group_name; add_to_group_name
          
          workflow_name = row[ 'workflow_name' ].strip
          workflow_belongs_to_group_names = row[ 'workflow_belongs_to_group_names' ].strip
            .split( "," ).collect { |str| str.strip }
          remove_from_group_name = row[ 'remove_from_group_name' ].strip
          add_to_group_name = row[ 'add_to_group_name' ].strip
          
          workflow_belongs_to_groups = workflow_belongs_to_group_names.collect do |group_name|
            wah.descendant_groups_by_name( group_name ).first if wah.descendant_groups_by_name( group_name ).count > 0
          end - [ nil ]
          remove_from_group = wah.descendant_groups_by_name( remove_from_group_name ).first
          add_to_group = wah.descendant_groups_by_name( add_to_group_name ).first

          for parent_group in workflow_belongs_to_groups
            workflow_counter += 1  
            
            # "Create workflow #{workflow_name} as child of group #{parent_group.name},"
            # "which moves the user from #{remove_from_group.name} to #{add_to_group.name}."
            
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
      p "Created #{workflow_counter} workflows for #{wah_counter} Wah groups."
      p "#{Wah.all.count - wah_counter} Wah groups didn't need modification."

    end
  end

  desc "Run all bootstrapping tasks"
  task :all => [ 
                :import_standard_workflows_for_wah_groups,
               ]

end
