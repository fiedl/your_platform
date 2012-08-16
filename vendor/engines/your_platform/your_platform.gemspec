$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "your_platform/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "your_platform"
  s.version     = YourPlatform::VERSION

  s.authors     = [ "Sebastian Fiedlschuster" ]
  s.email       = [ "sebastian@fiedlschuster.de" ]
  s.homepage    = "TODO"

  s.summary     = "TODO: Summary of YourPlatform."
  s.description = s.summary

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  # Dependencies 
  # --------------------------------------------------------------------------------

  s.add_dependency "rails", "~> 3.2.6"
  s.add_dependency "jquery-rails"

  # To use ActiveModel has_secure_password (password encryption)
  s.add_dependency 'bcrypt-ruby', '>= 3.0.1'                                           # MIT License 

  # Formtastic Form Helper,
  # see: https://github.com/justinfrench/formtastic,
  # http://rubydoc.info/gems/formtastic/frames
  s.add_dependency 'formtastic'                                                        # MIT License

  # File Uploads
  s.add_dependency 'carrierwave'                                                       # MIT License
  s.add_dependency 'rmagick'


  # Development Dependencies 
  # --------------------------------------------------------------------------------

  s.add_development_dependency "rspec-rails", "2.10.0"
  s.add_development_dependency "guard", "1.0.1"
  s.add_development_dependency "guard-rspec", "0.5.5"


end
