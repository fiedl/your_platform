trigger_selector = "#horizontal_nav ul.nav > li > a, a.breadcrumb_link"

$(document).on 'mouseenter', trigger_selector, (event)->
  trigger_link = $(this)
  vertical_nav_path = trigger_link.data('vertical-nav-path')

  if vertical_nav_path and trigger_link.closest('.dropdown-menu').size() == 0 and trigger_link.find('.dropdown-menu').size() == 0
    trigger_link.addClass('hover')
  
    $.get vertical_nav_path, (result)->
    
      if trigger_link.hasClass('hover')
        $('ul#nav_dropdown').remove()
        trigger_link.append('<ul id="nav_dropdown" class="dropdown-menu" role="menu"></ul>')
        $('ul#nav_dropdown').html(result)
        $('ul#nav_dropdown').css({
          "position": "absolute",
          "width": "200px",
          "top": trigger_link.position().top + trigger_link.closest('li').height(),
          "left": trigger_link.position().left
        })
        $('ul#nav_dropdown').show()
        $('ul#nav_dropdown li:not(.child)').hide()
  false

$(document).on 'mouseleave', trigger_selector, (event)->
  $(this).removeClass('hover')

$(document).on 'click', ->
  $('ul#nav_dropdown').remove()

$(document).on 'mouseleave', ('#nav_dropdown'), ->
  $(this).remove()
