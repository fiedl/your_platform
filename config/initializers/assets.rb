# This file lists the assets that need to be compiled into separate files.

# Layout
Rails.application.config.assets.precompile += %w( bootstrap_setup.css bootstrap_layout.css )

# Galleria
Rails.application.config.assets.precompile += %w( galleria-classic.js galleria/classic-loader.gif galleria/classic-map.png )