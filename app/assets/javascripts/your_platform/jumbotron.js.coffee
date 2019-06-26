$(document).ready ->
  if $('body').data('layout') == 'bootstrap'
    $('.box').each ->
      
      # Convert all boxes with h1 inside to jubotrons.
      # http://getbootstrap.com/components/#jumbotron
      #
      if $(this).find('.content h1').count() > 0
        $(this).find('.content').addClass('jumbotron')
        $(this).find('.page_body a').addClass('btn btn-lg btn-outline-secondary')
        $(this).find('.page_body a:first').addClass('btn-primary').removeClass('btn-outline-secondary')