
require 'csv'
require 'colored'


# This class handles import into the database.
# It is the super class for several special importers, such as the UserImporter.
#
class Importer

  def initialize( args = {} )
    self.file_name ||= args[:file_name]
    self.update_policy ||= args[:update_policy]
    self.filter ||= args[:filter]
  end

  # This attribute refers to the file name of the file to import
  #
  def file_name=( file_name )
    raise "File #{file_name} does not exist." if not File.exists? file_name
    @file_name = file_name
  end
  def file_name
    @file_name
  end

  # This attribute refers to the policy for existing entries.
  # Possible values:
  #
  #   :ignore, :update, :replace
  #
  # Defaults to `:ignore`.
  #
  def update_policy=(update_policy)
    unless [ :ignore, :update, :replace ].include? update_policy
      raise 'No valid update policy. Possible values: :ignore, :update, :replace.' 
    end
    @update_policy = update_policy
  end
  def update_policy
    @update_policy ||= :ignore
  end

  # This attribute refers to the filter applied to the import sequence.
  # The filter is a Hash defining attributes the records to import should have.
  # 
  # Example:
  #
  #   filter = { "uid" => "12345" }
  #
  def filter=( filter )
    raise "The filter should be a Hash like `{ \"uid\" => \"W64433\" }`." if not ( filter.kind_of?(Hash) || filter.nil? )
    @filter = filter
  end
  def filter
    @filter
  end

end


class ImportFile

  # Arguments for initialization:
  # 
  #   file_name
  #   data_class_name     e.g. "UserData"
  #
  def initialize( args = {} )
    @file_name = args[:file_name]
    @data_class_name = args[:data_class_name]

    raise "File #{@file_name} does not exist." if not File.exists? @file_name
    raise "Data class not found: #{@data_class_name}" if not @data_class_name.constantize.kind_of? Class
  end

  def each_row( &block )
    CSV.foreach( @file_name, headers: true, col_sep: ";" ) do |row|
      yield( @data_class_name.constantize.new( row.to_hash ) )
    end
  end

end




class ProgressIndicator

  def initialize
    STDOUT.sync = true
  end

  def indicate_success
    print ".".green
  end

  def indicate_failure
    print "F".red
  end

end
