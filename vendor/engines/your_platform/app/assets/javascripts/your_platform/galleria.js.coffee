ready = ->

  Galleria.configure({
    imageCrop: true,
    transition: 'slide',
    initialTransition: 'fade',
    assets: true,
    _toggleInfo: true,
    autoplay: 9000,
    popupLinks: true
  })
  
  Galleria.ready( ->
    this.bind('loadstart', (e)->
      title = e.galleriaData.title
      description = e.galleriaData.description
      $('.picture-title').hide().html(title).fadeIn(500)
      $('.picture-description').hide().html(description).fadeIn(500)
    )
  )
  
  Galleria.run '.galleria'
  
$(document).ready(ready)
$(document).on('page:load', ready)
