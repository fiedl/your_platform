# Do not store alert messages in cache. Otherwise, they would be shown
# when a page is restored from cache.
#
$(document).on 'turbolinks:before-cache', ->
  $(".alert").remove()
