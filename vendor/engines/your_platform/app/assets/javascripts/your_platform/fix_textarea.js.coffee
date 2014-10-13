ready = ->
  
  if $('textarea').size() > 0
    $('textarea').val($('textarea').val().replace(/^ {1,}/gm, ""))

$(document).ready(ready)
$(document).on('page:load', ready)