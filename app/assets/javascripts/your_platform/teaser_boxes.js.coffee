# See also:
# - boxes.js.coffee
# - boxes_of_equal_leight.js.coffee
# - drag_to_sort_boxes.js.coffee
#

# Clicking on the galleria image of a teaser box will follow the link
# rather than opening a lightbox.
#
$(document).ready ->
  $('.box.teaser_box .galleria').addClass('deactivate-auto-lightbox')

$(document).on 'click', '.box.teaser_box .galleria-image img', (e)->
  Turbolinks.visit $(this).closest('.box').find('h1.panel-title a').attr('href')
  e.preventDefault()
  e.stopPropagation()
  false
