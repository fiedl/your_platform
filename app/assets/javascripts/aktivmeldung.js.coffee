ready = ->

$(document).on 'click', '.aktivmeldung input[type=submit]', ->
  $(this).hide()
  $('.progress').removeClass('hidden').show()

$(document).ready(ready)
$(document).on('page:load', ready)
