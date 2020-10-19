# https://stackoverflow.com/a/57795518/2066546

$(document).ready ->
  if $('body').hasClass 'auto-dark-mode'
    App.activate_auto_dark_mode()

  # watch for changes
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener 'change', (e) ->
    if $('body').hasClass 'auto-dark-mode'
      if e.matches
        App.activate_dark_mode()
      else
        App.deactivate_dark_mode()

App.activate_dark_mode = ->
  $('body').addClass 'theme-dark'

App.deactivate_dark_mode = ->
  $('body').removeClass 'theme-dark'

# activate dark mode if the operating system prefers dark mode
#
App.activate_auto_dark_mode = ->
  $('body').addClass 'auto-dark-mode'
  if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches)
    App.activate_dark_mode()
  else
    App.deactivate_dark_mode()

App.deactivate_auto_dark_mode = ->
  $('body').removeClass 'auto-dark-mode'