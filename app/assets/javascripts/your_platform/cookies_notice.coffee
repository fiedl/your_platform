$(document).on 'click', '#cookies_notice_ok', ->
  $.ajax {
    type: 'POST',
    url: '/api/v1/discard_cookies_notice'
  }
  $('#cookies_notice').remove()