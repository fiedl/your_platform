concern :ReadOnlyMode do
  
  included do
    helper_method :read_only_mode?
  end
  
  # Read-only mode for maintenance purposes.
  #
  # To enable read-only mode:
  #
  #     touch tmp/read_only_mode
  #
  # To dactivate read-only mode:
  #
  #     rm tmp/read_only_mode
  #
  def read_only_mode?
    @read_only_mode ||= ActiveRecord::Base.read_only_mode?
  end
  
end