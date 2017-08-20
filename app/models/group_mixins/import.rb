# -*- coding: utf-8 -*-

# This module extends the Group model by group import methods.
# This allows, for example, to import groups from a previous application or to auto-load
# a certain default group structure.
#
# The module is included in the Group model by `include GroupMixins::Import`.
# The methods of the module can be accessed just like any other Group model methods:
#    Group.class_method()
#    g = Group.new()
#    g.instance_method()
#
module GroupMixins::Import

  extend ActiveSupport::Concern

  included do
  end


  # Hash Array Import
  # ==========================================================================================

  module ClassMethods

    # Import Hash Array of groups into a parent group.
    # Each group in the array is represented by a hash. Each hash contains the attributes
    # of the group. The group's children are represented by another hash array, which is
    # stored at the `children` key.
    #
    # The hash array should like this:
    #     [
    #         {
    #             :name => "Group 1",
    #             :children => [
    #                 {
    #                     :name => "Group 1.1"
    #                 },
    #                 {
    #                     :name => "Group 1.2"
    #                 }
    #             ]
    #         }
    #     ]
    #
    # This is a helper method, which is used by other import methods like
    # `json_import_groups_into_parent_group`.
    #
    def hash_array_import_groups_into_parent_group( hash_array_of_groups, parent_group )
      return unless hash_array_of_groups
      counter_for_created_groups = 0

      for new_group_hash in hash_array_of_groups do

        unless parent_group.children.select { |child| child.name == (new_group_hash["name"] || new_group_hash[:name]) }.count > 0

          # get children from hash
          sub_group_hash_array = new_group_hash[ "children" ]
          sub_group_hash_array = new_group_hash[ :children ] unless sub_group_hash_array
          new_group_hash.reject! { |key| key.to_sym == :children }

          # get domain from hash
          domain = new_group_hash[ "domain" ]
          new_group_hash.reject! { |key| key.to_sym == :domain }

          # create the new group
          g = Group.create( new_group_hash )
          g.parent_groups << parent_group
          g.set_flags_based_on_group_name
          g.save

          # import the child's children as well
          self.hash_array_import_groups_into_parent_group sub_group_hash_array, g if sub_group_hash_array
          counter_for_created_groups += 1

          # set domain as url component in navnode
          g.navnode.update_attribute(:url_component, "#{domain}/")
        end
      end

      return counter_for_created_groups.to_s + " groups created."
    end

    # Convert an array of group names, like
    #
    #   [ "Group 1",
    #     { "Group 2" => [ "Group 2.1", "Group 2.2" ] },
    #     ... ]
    #
    # into an array of hashes as used by the `hash_array_import_groups_into_parent_group`
    # method.  The result looks like this:
    #
    #   [
    #      { :name => "Group 1" },
    #      { :name => "Group 2", children: [
    #                                         { name: "Group 2.1" },
    #                                         { name: "Group 2.2" }
    #                                      ]
    #      },
    #      ...
    #   ]
    #
    # This method is used in the YAML import mechanism.
    #
    def convert_group_names_to_group_hashes( group_names )
      group_names.map do |array_item|
        if array_item.kind_of? String
          { name: array_item }
        elsif array_item.kind_of? Hash
          unless array_item[ :name ]
            { name: array_item.keys.first,
              children: convert_group_names_to_group_hashes( array_item[ array_item.keys.first ] )
            }
          end
        end
      end
    end

  end


  # CSV Import
  # ==========================================================================================

  module ClassMethods

    # Import groups listed in a comma-separated-values file (CSV) into a parent group.
    # The CSV format should look like this:
    #
    #    token;name
    #    GA;Group A
    #    GB;Group B
    #
    # Feel free to use other attributes in the CSV file as well. They will simply be
    # converted into a hash and then passed to a `create` method.
    #
    # Note: This script expects a semicolon (;) to be used as separator.
    #
    # The csv file is to be placed in the #{Rails.root}/import folder of the main
    # application. For the file #{Rails.root}/import/foo_groups.csv, call:
    #
    #    Group.csv_import_groups_into_parent_group( "foo_groups.csv", foo_parent_group )
    #
    def csv_import_groups_into_parent_group( csv_file_title, parent_group )
      import_file_name = File.join( Rails.root, "import", csv_file_title )
      require 'csv'
      CSV.foreach import_file_name, headers: true, col_sep: ';' do |row|

        new_child_group = Group.create row.to_hash
        parent_group.child_groups << new_child_group

      end
    end

  end


  # JSON Import
  # ==========================================================================================

  module ClassMethods

    # Import groups from a JSON format file into a parent group.
    # The JSON file should look like this:
    #
    #     [
    #         {
    #             "name": "Group 1",
    #             "children":
    #             [
    #                 {
    #                     "name": "Group 1.1"
    #                 },
    #                 {
    #                     "name": "Group 1.2",
    #                     "children":
    #                     [
    #                         {
    #                             "name": "Group 1.2.1"
    #                         },
    #                         {
    #                             "name": "Group 1.2.2"
    #                         }
    #                     ]
    #                 }
    #             ]
    #         },
    #         {
    #             "name": "Group 2"
    #         }
    #     ]
    #
    # The json file is to be placed in the #{Rails.root}/import folder of the main
    # application. For the file #{Rails.root}/import/foo_groups.json, call:
    #
    #    Group.json_import_groups_into_parent_group( "foo_groups.json", foo_parent_group )
    #
    def json_import_groups_into_parent_group( json_file_title, parent_group )
      raise RuntimeError, "no parent group given during import" unless parent_group
      import_json_file = File.open( File.join( Rails.root, "import", json_file_title ), "r" )
      json = IO.read( import_json_file )

      new_child_groups_hash_array = JSON.parse( json )
      p self.hash_array_import_groups_into_parent_group new_child_groups_hash_array, parent_group
    end

  end


  # YAML Import
  # ==========================================================================================

  module ClassMethods

    # Import the groups of a YAML file into a parent group.
    # The YAML file should look like this:
    #
    #   - Group 1
    #   - Group 2:
    #       - Group 2.1:
    #           - Group 2.1.1
    #           - Group 2.1.2
    #       - Group 2.2
    #   - Group 3:
    #       - Group 3.1
    #
    # The YAML files are expected to be stored in the `#{Rails.root}/import` directory
    # of the main application. For example, the file `#{Rails.root}/import/foo.yml`
    # is imported by calling:
    #
    #    Group.yaml_import_groups_into_parent_group( "foo.yml", parent_group )
    #
    def yaml_import_groups_into_parent_group( yaml_file_title, parent_group )
      yaml_file_name = File.join( Rails.root, "import", yaml_file_title )
      if File.exists? yaml_file_name

        sub_group_hashes = []
        File.open( yaml_file_name, "r" ) do |file|
          sub_group_hashes = YAML::load(file)
        end

        # This allows to use a short-form of yaml. Because of this, one doesn't need to
        # specify the `name` attribute in yaml, but can just use the group name as key,
        # like shown above in the description of the `yaml_import_groups_into_parent_group`
        # method.
        sub_group_hashes = convert_group_names_to_group_hashes( sub_group_hashes )

        Group.hash_array_import_groups_into_parent_group( sub_group_hashes, parent_group )

      else
        return false
      end
    end

  end


  # Import of the Default Sub-Structure of a Group
  # ==========================================================================================

  # Import the default group structure.
  # This is called after creation of the group.
  #
  # The structure is to be placed in a file at
  #   #{Rails.root}/import/default_group_sub_structures/#{self.name}.yml
  # and is to be formatted in yaml, like this:
  #
  #   - Group 1
  #   - Group 2:
  #       - Group 2.1:
  #           - Group 2.1.1
  #           - Group 2.1.2
  #       - Group 2.2
  #   - Group 3:
  #       - Group 3.1
  #
  def import_default_group_structure( yaml_file_title = nil )
    yaml_file_title ||= yaml_file_title = File.join( "default_group_sub_structures",
                                                     "#{self.name}.yml" )
    parent_group = self
    Group.yaml_import_groups_into_parent_group( yaml_file_title, parent_group )
  end


  # Special Groups
  # ==========================================================================================

  # When importing group structures, certain group names indicate special group attributes.
  # This method sets these flags based on the group name.
  #
  # This method is called by the `hash_array_import_groups_into_parent_group` method.
  #
  def set_flags_based_on_group_name

    # Officers
    set_flag_based_on_name :officers_parent

    # Guests
    set_flag_based_on_name :guests_parent

    # Deceased
    set_flag_based_on_name :deceased_parent

    # Former Members
    set_flag_based_on_name :former_members_parent

  end

  def set_flag_based_on_name( name )
    translations = []
    name = name.to_sym
    I18n.translate( name ) # required to initialize the I18n
    I18n.backend.send( :translations ).each do |language, translations_hash|
      translations << translations_hash[ name ]
    end
    if self.name.in? translations
      self.add_flag( name )
    end
  end

end
