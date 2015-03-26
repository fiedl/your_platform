ready = ->
  
  if $('.galleria').length

    

    Galleria.configure({
      #imageCrop: true,
      transition: 'slide',
      initialTransition: 'fade',
      assets: false,  # The images are not serverd as assets but by the attachments controller.
      _toggleInfo: true,
      preload: 10,
      #autoplay: 9000,
      popupLinks: false,
      trueFullscreen: false,
      #carousel: false,
      swipe: true,
    })
    
    Galleria.ready( ->
      gallery = this
      
      $(document).on 'click', '.galleria-stage img', (e)->
        gallery.toggleFullscreen()
        e.stopPropagation()
        e.preventDefault()
        false
        
      
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
      
    )
    
    $(document).on 'mouseenter', '.picture-title', ->
      $(this).find('.remove_button').show()
    $(document).on 'mouseleave', '.picture-title', ->
      $(this).find('.remove_button').hide()
      
    Galleria.run '.galleria', {
      responsive: true,
      #height: 0.625, # 16:10
      debug: false
      ## height: $(this).find('img').attr('height')
    }
    
  $('.galleria-errors').hide()
  
$(document).ready(ready)

