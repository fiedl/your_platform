# For public websites, scroll over to the start page of the current home page
# when reaching the end of the page content.

$(document).ready ->
  element = $('#scroll_over_to_home_page')
  element.hide()
  container = $('#content_area')
  if element.count() == 1
    url = element.data('url')
    $.ajax {
      url: url,
      data: {fast_lane: true},
      success: (result)->
        element.show()
        content_container = $(result).find('#content #content_area .row.box_configuration')
        content_container = $(result).find('#content #content_area') if content_container.count() == 0
        content = $(content_container[0].outerHTML)

        # Remove duplicate boxes
        content.find('.box').each ->
          box = $(this)
          if box.attr('id') && $('body').find("##{box.attr('id')}").count() > 0
            box.closest('.col').remove()

        container.append content
        container.find('.row:last').process()
    }