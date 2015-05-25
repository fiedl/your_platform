$(document).on 'edit', '.box', ->
  # This is needed for css styling.
  $(this).find('.content').addClass 'currently_in_edit_mode'
  
$(document).on 'save', '.box', ->
  $(this).find('.content').removeClass 'currently_in_edit_mode'
  
$(document).on 'cancel', '.box', ->
  $(this).find('.content').removeClass 'currently_in_edit_mode'
  
$(document).ready ->
  $('.content_twoCols_right > div.col-xs-12').each -> 
    $(this).find('.box:first').addClass('first')
