# This array will contain the galleria instances.
# It is used to destroy the instances with turbolinks.
# 
galleriaInstances = []

$(document).ready ->
  
  if $('.galleria').length
    
    # Basic galleria configuration.
    #
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
      debug: false
      ## height: $(this).find('img').attr('height')
    }
    
    # Initialize galleria. One has to load a theme here, 
    # even if the theme files have already been loaded through
    # the asset pipeline.
    #
    # Each instance of .galleria in the dom will generate
    # one instance of the Galleria object in javascript.
    # For each such instance, Galleria.ready is being called
    # below.
    #
    Galleria.loadTheme $('.galleria').data('theme-js-path')
    Galleria.run '.galleria'
    
    Galleria.ready ->
      newGalleriaInstance = this
      galleriaInstances.push(newGalleriaInstance)

      # When loading a gallery image, also update the description
      # shown below the image.
      # 
      this.bind 'loadfinish', (e)->
        if typeof(e.galleriaData) != 'undefined'
          # Transform the image path into the description json url.
          # /attachments/123/filename.png
          description_path = e.galleriaData.big.split("/").slice(0,3).join("/") + "/description.json"
          
          $.ajax({
            type: 'GET',
            url: description_path,
            success: (result) ->
              parent = $(e.target).first().parent().parent()
              $(parent).find('.picture-info')
                .hide()
                .replaceWith(result.html).show()
              $(parent).find('.picture-info')
                .find('.best_in_place').best_in_place()
              $(parent).find('.remove_button')
                .removeClass('show_only_in_edit_mode')  
                .hide()
          })
      
      # Hide thumbnail collections with less than 2 elements,
      # since they only confuse people there.
      #
      $('.galleria-thumbnails').each ->
        if $(this).find('.galleria-image').size() < 2
          $(this).hide()
        else
          $(this).show()            


  # Do not show galleria errors. These are not useful
  # in production.
  #  
  $('.galleria-errors').hide()


# Clicking on an gallery image switches to fullscreen mode,
# i.e. covers the full browser window.
#
$(document).on 'click', '.galleria-container:not(.fullscreen) .galleria-stage img', (e)->
  currentGalleriaInstance = $(this).closest('.galleria').data('galleria')
  if typeof(currentGalleriaInstance) != 'undefined'
    currentGalleriaInstance.enterFullscreen()
  e.stopPropagation()
  e.preventDefault()
  false
$(document).on 'click', '.galleria-container.fullscreen .galleria-stage img', (e)->
  galleriaInstances.forEach (galleriaInstance)->
    galleriaInstance.exitFullscreen()
      
# The button to remove an image is only to be shown when 
# hovering the image description.
# 
$(document).on 'mouseenter', '.picture-title', ->
  $(this).find('.remove_button').show()
$(document).on 'mouseleave', '.picture-title', ->
  $(this).find('.remove_button').hide()

# When turbolinks is starting to fetch a page, remove all
# galleria objects to avoid binding issues.
#
$(document).on "page:fetch", ->
  $('.galleria').remove()
  galleriaInstances.forEach (galleriaInstance)->
    galleriaInstance.destroy()
