trigger_selector = "#horizontal_nav ul.nav li a, #breadcrumb li a"

$(document).on 'mouseenter', trigger_selector, (event)->
  
  if $('.vertical_menu').data('new-menu-feature') # can? :use, :new_menu_feature
  
    trigger_link = $(this)
    vertical_nav_path = trigger_link.data('vertical-nav-path')
    
    if vertical_nav_path and trigger_link.closest('.dropdown-menu').size() == 0
      $.get vertical_nav_path, (result)->

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

$(document).on 'click', ->
  $('ul#nav_dropdown').remove()


timeout_id = 0
$(document).on 'mouseleave', ('#nav_dropdown, ' + trigger_selector), ->
  timeout_id = setTimeout ->
    $('ul#nav_dropdown').remove()
  , 400

$(document).on 'mouseenter', '#nav_dropdown', ->
  clearTimeout(timeout_id) if timeout_id != null
$(document).on 'mouseenter', trigger_selector, ->  
  clearTimeout(timeout_id) if timeout_id != null
