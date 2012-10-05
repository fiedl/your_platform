# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'your_platform/version'

Gem::Specification.new do |gem|
  gem.name          = "your_platform"
  gem.version       = YourPlatform::VERSION
  gem.authors       = ["Sebastian Fiedlschuster"]
  gem.email         = ["sebastian@fiedlschuster.de"]
  gem.description   = "Administrative and social network platform for closed user groups."
  gem.summary       = gem.description
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
