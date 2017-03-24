$(document).ready ->
  
  # In the memberships#index table,
  # this removes the tr when confirming membership deletion.
  #
  # The deletion itself is handled by rails:
  # remove_button helper.
  #
  $("table.memberships .remove_button").bind 'confirm:complete', (e, answer)->
    if (answer)
      $(this).closest('tr').remove()