$:.push File.expand_path("../lib", __FILE__)

# SEE ALSO
# https://github.com/fiedl/your_platform/blob/master/your_platform.gemspec

# Maintain your gem's version:
require "your_platform/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "your_platform"
  s.version     = YourPlatform::VERSION

  s.authors     = [ "Sebastian Fiedlschuster" ]
  s.email       = [ "sebastian@fiedlschuster.de" ]
  s.homepage    = "https://github.com/fiedl/your_platform"

  s.summary     = "Administrative and social network platform for closed user groups."
  s.description = s.summary

  s.files = Dir["{app,config,db,lib,vendor}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  # Dependencies 
  # --------------------------------------------------------------------------------

  # Rails and Rails Additions
  s.add_dependency "rails", "~> 3.2.6"
  s.add_dependency "rails-i18n"                                                        # MIT License

  # JavaScript 
  s.add_dependency "jquery-rails"

  # Data Structures
  # DAG Structure, https://github.com/resgraph/acts-as-dag
  s.add_dependency 'acts-as-dag', '>= 2.5.7'                                           # MIT License
  s.add_dependency 'acts_as_tree'                                                      # MIT License
  # make dag links paranoid, i.e. don't delete links, but only mark as deleted.
  s.add_dependency 'rails3_acts_as_paranoid'                                           # MIT License
  s.add_dependency 'acts_as_paranoid_dag'                                              # MIT License


  # To use ActiveModel has_secure_password (password encryption)
  s.add_dependency 'bcrypt-ruby', '>= 3.0.1'                                           # MIT License 

  # Template Engines
  # haml template language, http://haml.info
  s.add_dependency 'haml'                                                              # MIT License

  # Formtastic Form Helper,
  # see: https://github.com/justinfrench/formtastic,
  # http://rubydoc.info/gems/formtastic/frames
  s.add_dependency 'formtastic'                                                        # MIT License

  # File Uploads
  s.add_dependency 'carrierwave'                                                       # MIT License
  s.add_dependency 'rmagick', '>=2.13.2'

  # Phone Numbers Formatting
  s.add_dependency 'phony'                                         


  # Development Dependencies 
  # --------------------------------------------------------------------------------

  s.add_development_dependency "rspec-rails", "2.10.0"
  s.add_development_dependency "guard", "1.0.1"
  s.add_development_dependency "guard-rspec", "0.5.5"


end
