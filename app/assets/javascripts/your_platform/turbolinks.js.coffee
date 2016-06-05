$(document).ready ->
  Turbolinks.reload = ->
    Turbolinks.visit window.location

  Turbolinks.enableTransitionCache() if $('body').data('env') != 'test'
