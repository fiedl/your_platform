ready = ->
  $(".has_tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()
  
  $('.edit_mode_group').on('edit', ->
    $(this).find('.tooltip').hide()
  )

$(document).ready(ready)
$(document).on('page:load', ready)
