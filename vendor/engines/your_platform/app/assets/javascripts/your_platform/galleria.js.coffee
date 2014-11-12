ready = ->
  
  if $('.galleria').length

    Galleria.configure({
      imageCrop: true,
      transition: 'slide',
      initialTransition: 'fade',
      assets: false,  # The images are not serverd as assets but by the attachments controller.
      _toggleInfo: true,
      preload: 4,
      # autoplay: 9000,
      popupLinks: true
    })
    
    Galleria.ready( ->
      this.bind('loadstart', (e)->
        title = e.galleriaData.title
        description = e.galleriaData.description
        
        parent = $(e.target).first().parent().parent()
        $(parent).find('.picture-title').hide().html(title).fadeIn(500)
        $(parent).find('.picture-description').hide().html(description).fadeIn(500)
      )
    )
    
    Galleria.loadTheme '/js/vendor/galleria/themes/classic.js'
    Galleria.run '.galleria', {
      # height: $(this).find('img').attr('height')
    }
    
  $('.galleria-errors').hide()
  
$(document).ready(ready)

