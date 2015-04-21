redirect_to = ""

perform_redirect = ->
  # Do not send the request if the user has clicked
  # another menu item in the meantime.
  if $('.vertical_menu li.active a').attr('href') == redirect_to
    Turbolinks.visit redirect_to
    redirect_to = ""

# If the user clicks on a link in the vertical menu,
# for performancce reasons, the menu has to be loaded first.
#
# Therefore, turbolinks is delayed here, the new menu is loaded,
# and then turbolinks is triggered.
#
$(document).on 'click', '.vertical_menu a', (event)->
  if $('.vertical_menu').data('new-menu-feature') # can? :use, :new_menu_feature
  
    redirect_to = $(this).attr('href')
    vertical_nav_path = $(this).data('vertical-nav-path')
    if vertical_nav_path
      
      # Fade out the content area.
      $('.content_twoCols_right').fadeTo('fast', 0.2)
      
      # Menu animation: Take away un-needed elements and move
      # the new_active element to its new position.
      $('.vertical_menu li').removeClass('active')
      $(this).closest('li').addClass('new_active active')
      if $(this).closest('li').hasClass('child')
        $(this).closest('li').removeClass('child')
        $('.vertical_menu li.child:not(.new_active)').hide('blind')
      if $(this).closest('li').hasClass('ancestor')
        $(this).closest('li').removeClass('ancestor')
        $(this).closest('li').nextAll().fadeOut()
      
      # Get the new menu content.
      $.get vertical_nav_path, (result)->
        
        # Animate the new menu.
        $('.vertical_menu ul.nav').html(result)
        $('.vertical_menu ul.nav li.child').hide()
        $('.vertical_menu ul.nav li.child').each (index)->
          $(this).delay(20 * index).fadeIn()
        
        # Load the new page content.
        # But give the user some time to click another element
        # before starting the request in order to reduce
        # server load.
        setTimeout ->
          perform_redirect()
        , 5000
      
      # Prevent the original turbolinks behaviour.
      event.preventDefault()
      event.stopPropagation()
      false
    
# If the user moves the mouse to the main area, i.e. leaves the menu,
# then perform the redirect immediately.
#
$(document).on 'mouseenter', '.content_twoCols_right', ->
  if $('.vertical_menu').data('new-menu-feature') # can? :use, :new_menu_feature
    perform_redirect()