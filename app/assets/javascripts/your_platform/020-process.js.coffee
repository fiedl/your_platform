# Process asynchronously added content.
#
$(document).ready ->
  jQuery.fn.process = ->
    
    this.apply_edit_mode()
    
    this.find('.box.event .edit_button').hide()
    this.find('.box.event #ics_export').hide()
    
    App.attachments.process($(this))
          
    Galleria.configure {
      #imageCrop: true,
      transition: 'slide',
      initialTransition: 'fade',
      assets: false,  # The images are not serverd as assets but by the attachments controller.
      _toggleInfo: true,
      preload: 0,
      #autoplay: 9000,
      popupLinks: false,
      trueFullscreen: false,
      #carousel: false,
      swipe: true,
      responsive: true,
      #height: 0.625, # 16:10
      height: 0.5629, # 16:9
      debug: false,
      ## height: $(this).find('img').attr('height')
    }
    Galleria.loadTheme $('.galleria').data('theme-js-path')
    Galleria.run $(this).find('.galleria')
    
    