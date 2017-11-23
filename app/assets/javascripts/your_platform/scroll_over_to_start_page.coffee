# For public websites, scroll over to the start page of the current home page
# when reaching the end of the page content.

$(document).ready ->
  element = $('#scroll_over_to_home_page')
  container = $('#content_area')
  if element.count() == 1
    url = element.data('url')
    $.ajax {
      url: url,
      data: {fast_lane: true},
      success: (result)->
        content = $(result).find('#content #content_area .row.box_configuration')[0].outerHTML
        container.append content
        container.find('.row:last').process()
    }