# -*- coding: utf-8 -*-
require 'importers/importer'

#
# This file contains the code to import corporations without the wingolf-specific sub-structure.
# Import like this:
#
#   require 'importers/external_corporations_importer'
#   importer = ExternalCorporationsImporter.new( file_name: "path/to/csv/file", filter: { "token" => "La" },
#                                                update_policy: :update )
#   importer.import
#   Corporation.all  # will list all corporations
#
class ExternalCorporationsImporter < Importer
  def initialize( args = {} )
    super(args)
    @object_class_name = "Corporation"
  end
  
  def corporations_parent 
    @corporations_parent ||= Group.corporations_parent
  end
  
  def import
    import_file = ImportFile.new( file_name: @file_name, data_class_name: "CorporationData" )
    import_file.each_row do |data|
      if data.match?(@filter)
        handle_existing(data) do |corporation|
          
          # import attributes
          #
          corporation.token = data.token
          corporation.name = data.name
          corporation.extensive_name = data.extensive_name
          success = corporation.save
          
          # set parent group
          if success
            if not corporation.ancestor_groups.include? corporations_parent
              corporation.parent_groups << corporations_parent
              success = false if not corporation.reload.parent_groups.include? corporations_parent
            end
          end
          
          # add comment field
          #
          if success
            corporation.profile_fields.create(type: "ProfileFieldTypes::Description", value: data.comment)
          end
          
          # log
          #
          if success
            progress.log_success
          else
            progress.log_error({corporation_errors: corporation.errors})
          end
        end
      end
    end
    progress.print_status_report
  end
  
end

class CorporationData < ImportDataset
  def initialize( data_hash )
    @data_hash = data_hash
    @object_class_name = "Corporation"
  end
  def token
    data_hash_value(:token)
  end
  def name
    data_hash_value(:name)
  end
  def extensive_name
    data_hash_value(:extensive_name)
  end
  def comment
    data_hash_value(:comments)
  end
  
  # This looks for an object in the database that matches
  # the dataset to import. 
  #
  def already_imported_object
    Corporation.where(token: self.token).first
  end
end
