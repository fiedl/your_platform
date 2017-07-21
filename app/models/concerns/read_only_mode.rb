concern :ReadOnlyMode do

  def destroy
    raise RuntimeError, 'Read-Only Mode' if readonly?
    super
  end

  def readonly?
    ApplicationRecord.read_only_mode?
  end

  class_methods do

    def read_only_mode?
      # Read only mode only applies to the web server, not the console or rake tasks,
      # since they are used for maintenance during read-only mode.
      #
      @read_only_mode = (read_only_trigger? and not console? and not rake_task?) if not defined?(@read_only_mode)
      @read_only_mode
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
