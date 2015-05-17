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
      
      # We will save a clone of the vertical menu before 
      # starting the animation. The clone will be shown
      # after fetching a page from the turbolinks cache,
      # since we need the fetched menu to be in the state
      # before the animation.
      menu_before_animation = $('.vertical_menu').clone()
        .addClass('before-animation')
        .hide()
      $('.vertical_menu:not(.before-animation)')
        .addClass('animating')
        .after(menu_before_animation)
      
      # Menu animation: Take away un-needed elements and move
      # the new_active element to its new position.
      $('.vertical_menu.animating li').removeClass('active')
      $(this).closest('li').addClass('new_active active')
      if $(this).closest('li').hasClass('child')
        $(this).closest('li').removeClass('child')
        $('.vertical_menu.animating li.child:not(.new_active)').hide('blind')
      if $(this).closest('li').hasClass('ancestor')
        $(this).closest('li').removeClass('ancestor')
        $(this).closest('li').nextAll().fadeOut()
      
      # Get the new menu content.
      $.get vertical_nav_path, (result)->
        
        # Animate the new menu.
        $('.vertical_menu.animating ul.nav').html(result)
        $('.vertical_menu.animating ul.nav li.child').hide()
        $('.vertical_menu.animating ul.nav li.child').each (index)->
          $(this).delay(20 * index).fadeIn()
        
        # Load the new page content.
        # But wait just a little bit in order to give the menu ajax
        # time to be handled first. Otherwise, the menu animation
        # could be disrupted.
        setTimeout ->
          perform_redirect()
        , 100
      
      # Prevent the original turbolinks behaviour.
      event.preventDefault()
      event.stopPropagation()
      false

$(document).on 'page:change', ->
  # Fade the main content back in when restoring from cache.
  # Otherwise, the user will see a dimmed content when restoring the
  # turbolinks-cached content.
  $('.content_twoCols_right').fadeTo('fast', 1.0)
  
  # Also, restore the menu state before the animation.
  $('.vertical_menu.animating').remove()
  $('.vertical_menu.before-animation').show().removeClass('before-animation')
