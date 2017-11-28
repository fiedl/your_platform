$(document).ready ->

  App.rails_env = $('body').data('env')
  App.test_env = true if App.rails_env == "test"

  # Deactivate some animations in test env as they keep confusing
  # capybara, which finds the text but thinks the text is invisible.
  #
  if App.test_env
    jQuery.fx.off = true
    jQuery.support.transition = false # For Bootstrap, see https://github.com/twbs/bootstrap/pull/16157/files.
