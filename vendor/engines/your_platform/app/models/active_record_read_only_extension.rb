module ActiveRecordReadOnlyExtension
  extend ActiveSupport::Concern
  
  def destroy
    raise 'Read-Only Mode' if readonly?
    super
  end
  
  module ClassMethods
    def read_only_mode?
      # Read only mode only applies to the web server, not the console or rake tasks,
      # since they are used for maintenance during read-only mode.
      #
      @@read_only_mode = (read_only_trigger? and not console? and not rake_task?) if not defined?(@@read_only_mode)
      @@read_only_mode
    end
    def read_only_trigger?
      File.exist?(File.join(Rails.root, 'tmp/read_only_mode'))
    end
    def console?
      defined?(Rails::Console)
    end
    def rake_task?
      File.basename($0) == 'rake'
    end
  end
end

module ActiveRecord
  class Base
    def readonly?
      ActiveRecord::Base.read_only_mode?
    end
  end
end