$(document).ready ->
  
  $(document).on 'edit', '.box', ->
    # This is needed for css styling.
    $(this).find('.content').addClass 'currently_in_edit_mode'
    
  $(document).on 'save', '.box', ->
    $(this).find('.content').removeClass 'currently_in_edit_mode'
    
  $(document).on 'cancel', '.box', ->
    $(this).find('.content').removeClass 'currently_in_edit_mode'