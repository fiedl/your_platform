$(document).ready ->
  Turbolinks.reload = ->
    Turbolinks.visit window.location

  Turbolinks.enableTransitionCache() if $('body').data('env') != 'test'

# If the layout changes, then turbolinks does not load the changed layout.
# And if the navigational elements differ between the layouts, this can look
# quite strange.
#
# Thus, reload the page after a layout change occured in turbolinks.
# This way, the new layout gets loaded.
#
# This is not the most efficient way. Does anyone know how to do it better?
#
# See also:
# * https://github.com/turbolinks/turbolinks-classic
# * https://github.com/turbolinks/turbolinks/issues/19
#
current_layout = ""
$(document).ready ->
  new_layout = $('body').data('layout')
  if current_layout and new_layout
    if current_layout != new_layout
      location.reload()
  if new_layout
    current_layout = new_layout

# Do not store alert messages in cache. Otherwise, they would be shown
# when a page is restored from cache.
#
$(document).on 'turbolinks:before-cache', ->
  $(".alert").remove()
