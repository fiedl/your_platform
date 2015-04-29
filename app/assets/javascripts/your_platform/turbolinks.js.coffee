$(document).ready ->
  Turbolinks.enableTransitionCache() if $('body').data('env') != 'test'
