# This file is to be run to initialise some basic database entries, e.g. the root user group, etc.
# Execute by typing  'rake bootsrap:all'  after database migration.
# SF 2012-05-03

namespace :wingolf_groups do

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

  task set_default_nav_attributes: :environment do
    p "Task: Set default nav attributes"
    
    # make the sub-groups "Philister" and "Ehrenphilister" of the "Philisterschaft" groups
    # be slim in the vertical menu and in the breadcrumb.
    groups_to_slim = Wah.all.collect do |wah|
      wah.philisterschaft.child_groups.collect do |child_group|
        if child_group.name.in? [ "Philister", "Ehrenphilister" ]
          child_group
        else
          []
        end
      end
    end.flatten
    for group in groups_to_slim
      group.nav_node.slim_menu = true
      group.nav_node.slim_breadcrumb = true
      group.save
    end
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

  desc "Import BV groups"
  task import_bv_groups: :environment do
    p "Task: Import BV groups"
    Group.csv_import_groups_into_parent_group "groups_bvs.csv", Group.bvs
  end

  desc "Import groups: Philistervereine vertagter Wingolfsverbindungen"
  task import_wah_vertagte: :environment do
    p "Task: Import groups: Philistervereine vertagter Wingolfsverbindungen"
    require 'csv'
    file_name = File.join( Rails.root, "import", "groups_wah_vertagt.csv" )
    if File.exists? file_name
      counter = 0
      CSV.foreach file_name, headers: true, col_sep: ';' do |row|
        new_wah_group = Group.create( row.to_hash )
        new_wah_group.child_groups.create( name: "Philisterschaft" )
        new_wah_group.parent_groups << Group.wingolf_am_hochschulort
        counter += 1
      end
      p "Wah Groups created: " + counter.to_s
    end
  end

  desc "Run all bootstrapping tasks" # see: http://stackoverflow.com/questions/62201/how-and-whether-to-populate-rails-application-with-initial-data
  task :all => [ 
                :import_wingolf_am_hochschulort_groups,
                :import_sub_structure_of_wingolf_am_hochschulort_groups,
                :import_bv_mappings,
                :import_bv_groups,
                :import_wah_vertagte,
                :set_default_nav_attributes,
               ]

end
