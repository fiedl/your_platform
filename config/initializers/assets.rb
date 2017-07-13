# This file lists the assets that need to be compiled into separate files.

# Layout
Rails.application.config.assets.precompile += %w( bootstrap_setup.css bootstrap_layout.css )
Rails.application.config.assets.precompile += %w( iweb_layout.css )
Rails.application.config.assets.precompile += %w( compact_layout.css )
Rails.application.config.assets.precompile += %w( modern_layout.css )
Rails.application.config.assets.precompile += %w( mobile_layout.css )

# Galleria
Rails.application.config.assets.precompile += %w( galleria-classic.js galleria/classic-loader.gif galleria/classic-map.png )

# Password Strength
Rails.application.config.assets.precompile += %w( password_strength.js zxcvbn.js )

# Vendor Images
Rails.application.config.assets.precompile += %w( aiga_immigration.png )

# Separate layout javascripts
Rails.application.config.assets.precompile += %w( mobile.js )
Rails.application.config.assets.precompile += %w( iweb.js )


# Include node modules where javascript stuff lives.
# http://nithinbekal.com/posts/yarn-rails/
#
Rails.application.config.assets.paths << YourPlatform::Engine.root.join('app/javascripts')
Rails.application.config.assets.paths << YourPlatform::Engine.root.join('vendor/packs')
Rails.application.config.assets.paths << YourPlatform::Engine.root.join('node_modules')

