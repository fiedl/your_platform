$(document).ready ->
  $('.edit_authors_hosts_and_guests').hide()

$(document).on 'click', '.authors_hosts_and_guests a.trigger_edit', ->
  $('.authors_hosts_and_guests a.trigger_edit').remove()
  $('.show_authors_hosts_and_guests').remove()
  $('.edit_authors_hosts_and_guests').show()