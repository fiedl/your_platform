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
  
  Galleria.run '.galleria'
  
$(document).ready(ready)
$(document).on('page:load', ready)
