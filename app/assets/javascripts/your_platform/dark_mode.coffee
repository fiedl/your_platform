# https://stackoverflow.com/a/57795518/2066546

$(document).ready ->
  if $('body').hasClass 'auto-dark-mode'

    # activate dark mode if the operating system prefers dark mode
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches)
      activate_dark_mode()

    # watch for changes
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener 'change', (e) ->
      if e.matches
        activate_dark_mode()
      else
        deactivate_dark_mode()

activate_dark_mode = ->
  $('body').addClass 'theme-dark'

deactivate_dark_mode = ->
  $('body').removeClass 'theme-dark'

