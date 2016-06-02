$(document).ready ->
  $('.hidden_help').hide()

$(document).on 'click', '.show_hidden_help', ->
  $(this).closest('.box, .modal-dialog').find('.hidden_help').show('blind')
  $(this).hide('fade')

# For users that are too afraid to click the button:
#
$(document).on 'mouseenter', '.show_hidden_help', ->
  button = $(this)
  button.addClass 'hover'
  setTimeout (-> button.click() if button.hasClass('hover')), 3000

$(document).on 'mouseleave', '.show_hidden_help', ->
  $(this).removeClass 'hover'