$(document).ready ->
  if $('body.blogpost .cinema_bar').count() > 0
    $('.box_image').remove()
    $('.box_content .video').detach().appendTo('.cinema_bar')
