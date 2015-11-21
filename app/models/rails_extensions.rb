module RailsExtensions
  
  # Find out whether this is run through the `rails console`.
  #
  #     Rails.console?
  #     => true or false
  # 
  def console?
    Rails.const_defined?('Console') or Rails.const_defined?('Pry')
  end
  
  # Find out whether this is run through a `rake` task.
  #
  #     Rails.rake_task?
  #     => true or false
  # 
  def rake_task?
    File.basename($0) == 'rake'
  end
    
end

module Rails
  extend RailsExtensions
end