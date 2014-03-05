require 'importers/models/log'
require 'colored'

namespace :import do
  
  desc "Import BVs and BV-PLZ mappings."
  task :bvs => [
    'environment',
    'bootstrap:all',
    'bvs:print_info',
    'bvs:import_basic_bv_mappings',
    'bvs:import_bv_groups',
    'bvs:additional_mappings'
  ]
  
  namespace :bvs do
    
    task :print_info do
      log.head "Importing BVs and BV-PLZ mappings."
    end
    
    desc "Import BVs from PLZ list"
    task :import_basic_bv_mappings => [:environment, :print_info] do
      p "Task: Import BV mappings. This really will take a while."
      require 'csv'
      file_name = File.join( Rails.root, "import", "groups_bv_zuordnung.csv" )
      if File.exists? file_name
        counter = 0
        CSV.foreach file_name, headers: true, col_sep: ';' do |row|
          BvMapping.create( bv_name: row[ 'BV' ], plz: row[ 'PLZ' ] )
          counter += 1
        end
        p "BV Mappings created: " + counter.to_s
      else
        p "File Missing: import/groups_bv_zuordnung.csv !!"
      end
    end

    task :import_bv_groups => [:environment, :print_info] do
      print "\n" + "Task: Import BV groups. \n".cyan
      Group.csv_import_groups_into_parent_group "groups_bvs.csv", Group.bvs_parent
    end
    
    task :additional_mappings => [:environment, :print_info] do
      log.section "Ergänzungen zu BV-Zuordnungen importieren."
      
      BvMapping.find_or_create plz: '06193', bv_name: 'BV 23'
      
      log.success "Fertig."
    end
    
  end
  
  def log
    $log ||= Log.new
  end
  
end