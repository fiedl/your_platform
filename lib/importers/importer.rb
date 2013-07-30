
require 'csv'
require 'colored'


# This class handles import into the database.
# It is the super class for several special importers, such as the UserImporter.
#
class Importer

  def initialize( args = {} )
    self.file_name = args[:file_name]
    self.update_policy = args[:update_policy]
    self.filter = args[:filter]
    @object_class_name = ""  # e.g. "User"
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

  # This method accesses the progress an ProgressIndicator instance for this
  # import. Use this to log successful steps, warnings and failures, as well as
  # for a final status report.
  #
  def progress
    @progress_indicator ||= ProgressIndicator.new
  end
  
  # This deals with datasets that have been already imported
  # with regard to the update policy.
  #
  def handle_existing( data, &block )
    if data.already_imported?
      if update_policy == :ignore
        progress.log_ignore( { message: "Dataset already imported.", dataset: data.data_hash } ) 
        object = nil
      end
      if update_policy == :replace
        data.existing_user.destroy 
        object = @object_class_name.constantize.new  # e.g.  User.new 
      end
      if update_policy == :update
        object = data.already_imported_object
      end
      yield( object ) if update_policy == :update || update_policy == :replace
    else
      yield( @object_class_name.constantize.new )  # e.g.  User.new
    end
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

# This class represents one dataset to import from the datafile.
#
class ImportDataset
  def initialize( data_hash )
    @data_hash = data_hash
    @object_class_name = ""   # e.g. User
  end
  
  def data_hash
    @data_hash
  end
  
  def data_hash_value( key )
    val = @data_hash[ key ] 
    val ||= @data_hash[ key.to_s ]
  end

  def d( key )
    data_hash_value(key)
  end
  
  # The filter is a Hash the data_hash is compared against.
  # The method returns true if the data_hash contains the information
  # given in the filter hash.
  #
  # Example:
  #
  #   filter = { "uid" => "1234" }
  #
  def match?( filter )
    return true if filter.nil?
    return ( @data_hash.slice( *filter.keys ) == filter )
  end
  
  def already_imported?
    already_imported_object.to_b
  end

  def already_imported_object
    if self.respond_to?(:id) && self.id
      @object_class_name.constantize.where( id: self.id ).first 
    end
  end
  
end


class ProgressIndicator

  def initialize
    STDOUT.sync = true
    @failures = []
    @warnings = []
    @ignores = []
    @counters = { success: 0, failure: 0, warning: 0, ignored: 0 }
  end

  def log_success
    print ".".green
    @counters[:success] += 1
  end

  # This method logs a failure. It prints a red "F" and logs the given
  # failure_report for output when calling `print_status_report`.
  # 
  # The failure_report may be any object of your liking, e.g. a String
  # or a Hash.
  #
  def log_failure( failure_report = nil )
    print "F".red
    @counters[:failure] += 1
    @failures << failure_report if failure_report
  end

  # See `log_failure`.
  #
  def log_warning( warning_report = nil )
    print "w".yellow
    @counters[:warning] += 1
    @warnings << warning_report if warning_report
  end

  def log_ignore( ignore_report = nil )
    print "."
    @counters[:ignored] += 1
    @ignores << ignore_report if ignore_report
  end

  def print_status_report
    print "\n"
    print "Import Finished. "
    print "#{@counters[:ignored]} ignored. "
    print "#{@counters[:success]} successful imports. ".green
    print "#{@counters[:warning]} warnings. ".yellow
    print "#{@counters[:failure]} failures.".red
    print "\n"

    if @ignores.count > 0
      print "\nIgnored:\n".white
      puts @ignores
    end
    if @warnings.count > 0
      print "\nWarnings:\n".yellow
      puts @warnings
    end
    if @failures.count > 0
      print "\nFailures:\n".red
      puts @failures
    end
    
  end

end
