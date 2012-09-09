# -*- coding: utf-8 -*-
# This file is to be run to initialise some basic database entries, e.g. the root user group, etc.
# Execute by typing  'rake bootsrap:all'  after database migration.
# SF 2012-05-03

namespace :bootstrap do

  desc "Add basic groups"
  task basic_groups: :environment do
    p "Task: Add basic groups"

    # Group 'Everyone' / 'Jeder'
    unless Group.everyone
      everyone = Group.create( name: 'Everyone' )
      everyone.add_flag( :everyone )
      everyone.name = I18n.translate( :everyone ) # "Jeder"
      everyone.save
    end

    # Corporations Parent Group ("Wingolf am Hochschulort")
    unless Group.find_corporations_parent
      corporations_parent = Group.create( name: "Corporations" )
      corporations_parent.add_flag( :corporations_parent )
      corporations_parent.parent_groups << Group.everyone
      corporations_parent.name = I18n.translate( :corporations_parent ) # "Wingolf am Hochschulort"
      corporations_parent.save
    end

    # Bvs Parent Group ("Bezirksverbände")
    unless Group.bvs_parent 
      bvs_parent = Group.create( "Bezirksverbände" )
      bvs_parent.add_flag( :bvs_parent )
      bvs_parent.parent_groups << Group.everyone
      bvs_parent.name = I18n.translate( :bvs_parent ) # "Bezirksverbände"
      bvs_parent.save
    end

  end

  desc "Set some nav node properties of the basic groups"
  task basic_nav_node_properties: :environment do
    p "Task: Set some basic nav node properties"
    n = Group.jeder.nav_node; n.slim_menu = true; n.slim_breadcrumb = true; n.save; n = nil
    n = Group.wingolf_am_hochschulort.nav_node; n.slim_menu = true; n.slim_breadcrumb = true; n.save; n = nil
  end

  desc "Add basic pages"
  task add_basic_pages: :environment do
    p "Task: Add basic pages."
    home = Page.create( title: "wingolf.org" )
    home.add_flag :root
    mitglieder_start = home.child_pages.create( title: "Mitglieder Start" )
    mitglieder_start.add_flag :intranet_root
    mitglieder_start.child_groups << Group.jeder
  end

  task add_flags_to_basic_pages: :environment do
    p "Task: Add Flags to Basic Pages"
    Page.find_by_title( "wingolf.org" ).add_flag :root
    Page.find_by_title( "Mitglieder Start" ).add_flag :intranet_root 
  end

  desc "Run all bootstrapping tasks" # see: http://stackoverflow.com/questions/62201/how-and-whether-to-populate-rails-application-with-initial-data
  task :all => [ 
                :basic_groups, 
                :basic_nav_node_properties,
                :add_basic_pages
               ]

end
