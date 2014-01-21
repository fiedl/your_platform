# -*- coding: utf-8 -*-

namespace :wingolf_groups do

  require 'colored'
  

  desc "Import all wingolf_am_hochschulort groups"
  task import_wingolf_am_hochschulort_groups: :environment do
    p "Task: Import wingolf_am_hochschulort groups"
    Group.json_import_groups_into_parent_group "groups_wingolf_am_hochschulort.json", Group.corporations_parent
  end

  task import_sub_structure_of_wingolf_am_hochschulort_groups: :environment do
    STDOUT.sync = true
    print "\n" + "Task: Import default substructure for wingolf_am_hochschulort groups. \n".cyan

    counter = 0
    Group.corporations.each do |corporation|
      if corporation.child_groups.count == 0
        if corporation.import_default_group_structure "default_group_sub_structures/wingolf_am_hochschulort_children.yml"
          counter += 1
          print ".".green
        else
          print ".".red
        end
      else
        print ".".yellow # nothing to do for this group
      end
    end
    print "\n" + ( "Added sub structure for " + counter.to_s + " groups.\n" ).green
  end

  # Dieser Task importiert die Gruppenstruktur für Wingolf-am-Hochschulort-Gruppen,
  # ohne darauf Rücksicht zu nehmen, ob die Korporationen bereits Untergruppen besitzen.
  # Warnung! Es ist nur sehr unwahrscheinlich, dass dieser Task ausgeführt wird, sobald das System
  # im Produktivbetrieb ist, da hiermit individuelle Anpassungen der einzelnen Verbindungen
  # vereitelt werden können.
  #
  task import_and_update_sub_structure_of_wah_groups: :environment do
    Group.corporations.each do |corporation|
      corporation.import_default_group_structure "default_group_sub_structures/wingolf_am_hochschulort_children.yml"
    end
  end

  task set_default_nav_attributes: :environment do
    p "Task: Set default nav attributes"
    
    # make the sub-groups "Philister" and "Ehrenphilister" of the "Philisterschaft" groups
    # be slim in the vertical menu and in the breadcrumb.
    groups_to_slim = Corporation.all.collect do |wah|
      if wah.philisterschaft
        wah.philisterschaft.child_groups.collect do |child_group|
          if child_group.name.in? [ "Philister", "Ehrenphilister" ]
            child_group
          else
            []
          end
        end
      end
    end.flatten
    for group in groups_to_slim
      if group
        group.nav_node.slim_menu = true
        group.nav_node.slim_breadcrumb = true
        group.save
      end
    end
  end

  desc "Import BVs from PLZ list"
  task import_bv_mappings: :environment do
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

  task import_bv_groups: :environment do
    print "\n" + "Task: Import BV groups. \n".cyan
    Group.csv_import_groups_into_parent_group "groups_bvs.csv", Group.bvs_parent
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
        new_wah_group.parent_groups << Group.corporations_parent
        counter += 1
      end
      p "Wah Groups created: " + counter.to_s
    end
  end

  task add_erstbandphilister_parent_groups: :environment do
    print "\n" + "Task: Add Erstbandphilister Parent Groups. \n".cyan
    Group.create_erstbandphilister_parent_groups
  end

  desc "Run all bootstrapping tasks" # see: http://stackoverflow.com/questions/62201/how-and-whether-to-populate-rails-application-with-initial-data
  task :all => [ 
                :import_wingolf_am_hochschulort_groups,
                :import_sub_structure_of_wingolf_am_hochschulort_groups,
                :import_bv_mappings,
                :import_bv_groups,
                :import_wah_vertagte,
                :set_default_nav_attributes,
                :add_erstbandphilister_parent_groups
               ]

end
