$(document).ready ->
  
  $('.new_post .post_tools').hide()
  $('.new_post textarea').autosize()
  
$(document).on 'change keyup paste', '.new_post textarea', ->
  if $('.new_post textarea').val() != ""
    $('.new_post .post_tools').show()
  else
    $('.new_post .post_tools').hide()

$(document).on 'focus', '.new_post textarea', ->
  if $('.new_post textarea').val() != ""
    $('.new_post .post_tools').show()

  