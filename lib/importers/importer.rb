
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
