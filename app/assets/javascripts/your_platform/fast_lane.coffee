$(document).ready ->

  if $('body').hasClass('fast-lane')
    $.get '/api/v1/current_role', {object_gid: $('body').data('navable')}, (current_role)->
      if current_role['officer?']
        separator = "?"
        separator = "&" if window.location.href.indexOf("?") > -1
        Turbolinks.visit_without_scrolling(window.location + separator + "no_fast_lane=true")

  else if window.location.href.indexOf('no_fast_lane') > -1
    history.pushState(null, null, window.location.href.replace('?no_fast_lane=true', '').replace('&no_fast_lane=true', ''))


