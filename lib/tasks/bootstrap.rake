# -*- coding: utf-8 -*-
# This file is to be run to initialise some basic database entries, e.g. the root user group, etc.
# Execute by typing  'rake bootsrap:all'  after database migration.
# SF 2012-05-03

namespace :bootstrap do

  desc "Add basic groups"
  task basic_groups: :environment do
    p "Task: Add basic groups"

    # Group 'Everyone' / 'Jeder'
    Group.create_everyone_group unless Group.everyone
    Group.find_everyone_group.update_attributes( name: "Jeder" )

    # Corporations Parent Group ("Wingolf am Hochschulort")
    Group.create_corporations_parent_group unless Group.corporations_parent
    Group.find_corporations_parent_group.update_attributes( name: "Wingolf am Hochschulort" )

    # Bvs Parent Group ("Bezirksverbände")
    Group.create_bvs_parent_group unless Group.bvs_parent
    Group.find_bvs_parent_group.update_attributes( name: "Bezirksverbände" )

  end

  desc "Set some nav node properties of the basic groups"
  task basic_nav_node_properties: :environment do
    p "Task: Set some basic nav node properties"
    n = Group.everyone.nav_node; n.slim_menu = true; n.slim_breadcrumb = true; n.save; n = nil
    n = Group.corporations_parent.nav_node; n.slim_menu = true; n.slim_breadcrumb = true; n.save; n = nil
  end

  desc "Add basic pages"
  task add_basic_pages: :environment do
    p "Task: Add basic pages."
    home = Page.create_root
    home.update_attributes(title: "wingolf.org")

    mitglieder_start = Page.create_intranet_root
    mitglieder_start.update_attributes(title: "Mitglieder-Start")
    mitglieder_start.child_groups << Group.everyone
  end

  desc "Add help page"
  task add_help_page: :environment do
    p "Task: Add help page."
    help = Page.create_help_page
    help.update_attributes(title: "Hilfe")
    help.parent_pages << Page.find_by_flag( :intranet_root )
    help.child_groups << Group.everyone
  end

  task add_flags_to_basic_pages: :environment do
    p "Task: Add Flags to Basic Pages"
    Page.find_by_title( "wingolf.org" ).add_flag :root
    Page.find_by_title( "Mitglieder Start" ).add_flag :intranet_root
    Page.find_by_title( "Hilfe" ).add_flag :help
  end

  task wbl_abo_group: :environment do
    p "Task: Adding Wingolfsblätter Abo Group"
    Group.find_or_create_wbl_abo_group
  end

  desc "Run all bootstrapping tasks" # see: http://stackoverflow.com/questions/62201/how-and-whether-to-populate-rails-application-with-initial-data
  task :all => [
                :basic_groups,
                :basic_nav_node_properties,
                :add_basic_pages,
                :add_help_page,
                :wbl_abo_group
               ]

end
