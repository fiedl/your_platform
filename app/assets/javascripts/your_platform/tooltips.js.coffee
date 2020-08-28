$(document).ready ->
  setTimeout ->
    $(".has_tooltip").tooltip()
    $('[data-toggle="tooltip"]').tooltip()
    $("a[rel=tooltip]").tooltip()
  , 1000
