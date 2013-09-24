ready = ->
  $("a[rel=popover]").popover()
  $(".has_tooltip").tooltip()
  $("a[rel=tooltip]").tooltip()

$(document).ready(ready)
$(document).on('page:load', ready)
