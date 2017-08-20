$(document).ready ->
  $('.hidden_help').hide()
  $('.hidden_help').addClass('alert alert-info')
  $('.hidden_help').prepend("<i class='fa fa-info-circle'></i>")

  # Add help tool buttons to those boxes that contain `.hidden_help` paragraphs.
  #
  $('.box').each ->
    box = $(this)
    if box.find('.hidden_help').count() > 0 and box.find('.show_hidden_help').count() == 0
      box_toolbar = box.find('.box_toolbar').first()
      help_button = $("<a href='#' class='show_hidden_help btn btn-default'><i class='fa fa-info-circle'></i></a>")
      help_button.attr('title', I18n.t('help'))
      box_toolbar.prepend(help_button)

$(document).on 'click', '.show_hidden_help', ->
  $(this).closest('.box, .modal-dialog').find('.hidden_help').show 'blind', ->
    $(this).attr('style', '')
  $(this).hide('fade')
  false

# For users that are too afraid to click the button:
#
$(document).on 'mouseenter', '.show_hidden_help', ->
  button = $(this)
  button.addClass 'hover'
  setTimeout (-> button.click() if button.hasClass('hover')), 3000

$(document).on 'mouseleave', '.show_hidden_help', ->
  $(this).removeClass 'hover'