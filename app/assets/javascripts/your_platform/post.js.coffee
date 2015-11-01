turbolinks_options = {
  change: ['post-deliveries'],
  showProgressBar: false,
  scroll: false 
}

reload_delivery_status = ->
  if $('#post-deliveries').size() > 0 
    if $('#post-deliveries').data('keep-polling')

      # FIXME: `showProgressBar: false` does not suffice, apparently.
      Turbolinks.ProgressBar.disable()

      Turbolinks.visit(window.location.pathname, turbolinks_options)
      setTimeout reload_delivery_status, 10000

$(document).ready ->
  if $('#post-deliveries').size() > 0
    setTimeout reload_delivery_status, 5000

