$(document).ready ->

  # In order to have the column classes work correctly for draggable boxes,
  # move the vertical nav col into the draggable-boxes row.
  # Otherwise, the box widths would depend on whether the vertical menu
  # is shown or not.
  #
  if $('.content_col .row.box_configuration').count() > 0
    vertical_nav_col = $('.vertical_nav_col')
    vertical_nav_col.detach()
    vertical_nav_col.prependTo($('.content_col .row.box_configuration'))
    $('.content_col').removeClass('col-sm-9').addClass('.col-sm-12')
