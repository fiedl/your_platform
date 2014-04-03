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
      
      BvMapping.find_or_create plz: '01067', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01069', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01097', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01099', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01127', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01129', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01139', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01157', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01187', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01219', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01277', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01309', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01328', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01454', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01458', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01809', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01844', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '01906', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04103', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04107', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04109', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04155', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04159', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04177', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04179', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04229', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04275', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04299', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04315', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04318', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04416', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04420', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04442', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04509', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04600', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04655', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04720', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04862', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04886', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '04895', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '06110', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06112', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06114', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06116', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06118', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06120', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06193', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06179', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06217', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06268', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06343', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06493', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06567', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06618', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06648', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06779', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06844', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06846', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06862', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '06886', bv_name: 'BV 23'
      BvMapping.find_or_create plz: '07381', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07407', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07546', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07646', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07743', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07745', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07747', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07749', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07751', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '07955', bv_name: 'BV 28'
      BvMapping.find_or_create plz: '08064', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '08340', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '08451', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '08539', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09116', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09123', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09126', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09127', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09130', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09212', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09217', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09353', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09434', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09517', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '09618', bv_name: 'BV 42'
      BvMapping.find_or_create plz: '16827', bv_name: 'BV 01'
      BvMapping.find_or_create plz: '23689', bv_name: 'BV 03'
      BvMapping.find_or_create plz: '40885', bv_name: 'BV 19b'
      BvMapping.find_or_create plz: '53125', bv_name: 'BV 20'
      BvMapping.find_or_create plz: '81373', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '82432', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '83371', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '83565', bv_name: 'BV 38'
      BvMapping.find_or_create plz: '85598', bv_name: 'BV 38'
      
      log.success "Fertig."
    end
    
  end
  
  def log
    $log ||= Log.new
  end
  
end