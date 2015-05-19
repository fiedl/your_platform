$(document).on 'click', '#notifications_menu .read_all a', ->
  $('#notifications_menu ul').hide('blind')
  $('#notifications_menu .badge').hide()