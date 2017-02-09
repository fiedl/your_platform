$(document).on 'click', '#select_teaser_image img', ->
  img = $(this)
  new_image_url = img.attr('src')

  $('#select_teaser_image img').removeClass 'active'
  img.addClass 'active'

  $('#select_teaser_image .best_in_place').click()
  setTimeout ->
    $('#select_teaser_image .best_in_place input').val new_image_url
    unless $('#select_teaser_image').closest('.box').hasClass('currently_in_edit_mode')
      $('#select_teaser_image .best_in_place').trigger 'save'
  , 100

