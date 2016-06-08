# $(document).ready ->
#   $('.shown_on_edit_button_hover').hide()
#   $('.shown_on_box_header_hover').hide()
# # Moved to `boxes.js.coffee`.

$(document).on 'mouseenter', '.edit_button', ->
  $(this).closest('.box').find('.shown_on_edit_button_hover').show('fade')

$(document).on 'mouseenter', '.panel-heading', ->
  $(this).closest('.box').find('.shown_on_box_header_hover').show('fade')

$(document).on 'mouseleave', '.panel-heading', ->
  $(this).find('.shown_on_edit_button_hover').hide('fade')
  $(this).find('.shown_on_box_header_hover').hide('fade')
