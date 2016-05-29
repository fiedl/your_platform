$(document).ready ->
  $('.modal').on 'shown.bs.modal', ->
    $(this).find('input[type="text"]').first().focus()

$(document).on 'click', '.modal input[type="submit"]', ->
  $(this).closest('.modal').modal('hide')