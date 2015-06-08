# This file lists the assets that need to be compiled into separate files.

# Layout
Rails.application.config.assets.precompile += %w( bootstrap_setup.css bootstrap_layout.css compact_layout.css )

# Galleria
Rails.application.config.assets.precompile += %w( galleria-classic.js galleria/classic-loader.gif galleria/classic-map.png )

# Password Strength
Rails.application.config.assets.precompile += %w( password_strength.js zxcvbn.js )

# Vendor Images
Rails.application.config.assets.precompile += %w( aiga_immigration.png )