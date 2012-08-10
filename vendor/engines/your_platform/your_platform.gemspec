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
  s.description = "TODO: Description of YourPlatform."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.6"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "sqlite3"
end
