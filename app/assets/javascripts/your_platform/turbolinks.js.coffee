# Do not store alert messages in cache. Otherwise, they would be shown
# when a page is restored from cache.
#
$(document).on 'turbolinks:before-cache', ->
  $(".alert").remove()
  App.spinner.hide()

App.spinner = {
  hide: ->
    $(".spinner").remove()
    $(".hidden-by-spinner").removeClass('hidden-by-spinner')
  show: (link)->
    link.find('img, i, .glyphicon').addClass('hidden-by-spinner')
    link.prepend('<span class="spinner"></span>')
}

$(document).on 'turbolinks:click', (event)->
  button = $(event.target)
  App.spinner.hide()
  App.spinner.show(button)