# This file will overwrite some behaviour of 
# https://github.com/rails/rails/blob/v3.2.3/actionpack/lib/sprockets/assets.rake#L69.
#
# Only the cache of `tmp/cache/assets` should be cleared, not `tmp/cache`.
#

require 'fileutils'

namespace :assets do
  namespace :precompile do
    task :primary => ["assets:environment", "clear_only_assets_cache"] do
      internal_precompile
    end

    task :nondigest => ["assets:environment", "clear_only_assets_cache"] do
      internal_precompile(false)
    end

    task :clear_only_assets_cache do
      FileUtils.rm_r('tmp/cache/assets')
    end
  end
end