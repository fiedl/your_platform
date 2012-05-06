# This file is to be run to initialise some basic database entries, e.g. the root user group, etc.
# Execute by typing  'rake bootsrap:all'  after database migration.
# SF 2012-05-03

namespace :bootstrap do
  desc "Add basic groups"
  task basic_groups: :environment do
    p "Task: Add basic groups"
    Group.jeder!
    Group.wingolf_am_hochschulort!
    Group.bvs!
  end

  desc "Import all wingolf_am_hochschulort groups"
  task import_wingolf_am_hochschulort_groups: :environment do
    p "Task: Import wingolf_am_hochschulort groups"
    Group.json_import_groups_into_parent_group "groups_wingolf_am_hochschulort.json", Group.wingolf_am_hochschulort
  end

  desc "Import default sub structure for wingolf_am_hochschulort groups"
  task import_sub_structure_of_wingolf_am_hochschulort_groups: :environment do
    p "Task: Import default substructure for wingolf_am_hochschulort groups"
    counter = 0
    Group.wingolf_am_hochschulort.child_groups.each do |woh_group|
      if woh_group.child_groups.count == 0
        woh_group.import_default_group_structure "wingolf_am_hochschulort_children.yml"
        counter += 1
      end
    end
    p "Added sub structure for " + counter.to_s + " groups."
  end

  desc "Set some nav node properties of the basic groups"
  task basic_nav_node_properties: :environment do
    p "Task: Set some basic nav node properties"
    n = Group.jeder.nav_node; n.slim_menu = true; n.slim_breadcrumb = true; n.save; n = nil
    n = Group.wingolf_am_hochschulort.nav_node; n.slim_menu = true; n.slim_breadcrumb = true; n.save; n = nil
  end

  desc "Import BVs from PLZ list"
  task import_bv_mappings: :environment do
    p "Task: Import BV mappings. This really will take a while."
    require 'csv'
    file_name = File.join( Rails.root, "import", "bv_zuordnung.csv" )
    if File.exists? file_name
      counter = 0
      CSV.foreach file_name, headers: true, col_sep: ';' do |row|
        BvMapping.create( bv_name: row[ 'BV' ], plz: row[ 'PLZ' ] )
        counter += 1
      end
      p "BV Mappings created: " + counter.to_s
    end
  end

  desc "Run all bootstrapping tasks" # see: http://stackoverflow.com/questions/62201/how-and-whether-to-populate-rails-application-with-initial-data
  task :all => [ 
                :basic_groups, 
                :import_wingolf_am_hochschulort_groups,
                :import_sub_structure_of_wingolf_am_hochschulort_groups,
                :basic_nav_node_properties,
                :import_bv_mappings
               ]

end
