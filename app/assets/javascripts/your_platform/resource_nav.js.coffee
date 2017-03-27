$(document).ready ->
  current_tab = $('body').data('tab')

  $('#resource_nav li').removeClass 'active'
  $("#resource_nav li.#{current_tab}").addClass 'active'

$(document).on 'mouseenter', '#resource_nav > ul > li', ->
  $(this).find('.dropdown-menu').show()