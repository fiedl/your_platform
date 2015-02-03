# YourPlatform Dependencies
require "your_platform/engine"

# Overrides for gems
require_dependency YourPlatform::Engine.root.join('lib/best_in_place/helper').to_s
require_dependency YourPlatform::Engine.root.join('lib/best_in_place/controller_extensions').to_s

module YourPlatform
end
