$(document).on 'mouseenter', '.edit_button', ->
  if not $(this).closest('edit_mode_group').hasClass('currently_in_edit_mode')
    $(this).closest('.box').find('.shown_on_edit_button_hover').css('visibility', 'visible')

$(document).on 'mouseenter', '.box_tools', ->
  if not $(this).closest('edit_mode_group').hasClass('currently_in_edit_mode')
    $(this).closest('.box').find('.shown_on_box_header_hover').css('visibility', 'visible')

$(document).on 'mouseleave', '.box_tools', ->
  $(this).find('.shown_on_edit_button_hover').css('visibility', 'hidden')
  $(this).find('.shown_on_box_header_hover').css('visibility', 'hidden')
