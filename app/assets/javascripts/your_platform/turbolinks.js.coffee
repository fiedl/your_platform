$(document).ready ->
  Turbolinks.reload = ->
    Turbolinks.visit window.location

  Turbolinks.visit_without_scrolling = (url)->
    # https://github.com/turbolinks/turbolinks/issues/140#issue-165184088
    originalScroll = Turbolinks.Visit.prototype.performScroll
    Turbolinks.Visit.prototype.performScroll = (-> null)
    resetScroll = ->
      Turbolinks.Visit.prototype.performScroll = originalScroll
      document.removeEventListener("turbolinks:load", resetScroll)
    document.addEventListener("turbolinks:load", resetScroll)
    Turbolinks.visit(url, {action: 'replace'})


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
  unless $('body').hasClass('mobile')
    button = $(event.target)
    App.spinner.hide()
    App.spinner.show(button)

$(document).on 'turbolinks:request-start', (event)->
  unless $('body').hasClass('mobile')
    $("html, body").animate {scrollTop: 0}, 300, 'swing' #, ->
    $('#content > div')
      .css('-webkit-transition', 'opacity 0.3s ease-out').css('opacity', '0')
      .hide('scale', {percent: 90}, 300)

$(document).on 'turbolinks:render', (event)->
  $('#content > div').css('opacity', '1').show()