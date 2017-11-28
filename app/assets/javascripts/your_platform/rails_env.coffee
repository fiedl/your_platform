$(document).ready ->

  App.rails_env = $('body').data('env')
  App.test_env = true if App.rails_env == "test"
