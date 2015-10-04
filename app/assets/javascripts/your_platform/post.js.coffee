reload_delivery_status = ->
  if $('#post-deliveries').size() > 0
    Turbolinks.visit(window.location.pathname, { change: ['post-deliveries'] })
    setTimeout reload_delivery_status, 10000

$(document).ready ->
  if $('#post-deliveries').size() > 0
    setTimeout reload_delivery_status, 5000

