# We need to modify galleria and tell it not to load css files
# from themes manually. We load the theme css using the asset
# pipeline of rails.

orig_add_theme_function = Galleria.addTheme
Galleria.addTheme = (theme)->
  # https://github.com/worseisbetter/galleria/blob/master/src/galleria.js#L5685

  theme.css = null
  orig_add_theme_function(theme)