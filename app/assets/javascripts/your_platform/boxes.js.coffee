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

$.fn.process_box_tools = ->
  this.find('.box.event .edit_button').hide()
  this.find('.box.event #ics_export').hide()
  this.find('.archive_button').hide()
  this.find('.show_activities_button').hide()
  this.find('.manage_attachments_button').hide()

  this.find('.box .box_header .tool').each ->
    tool = $(this)
    box_toolbar = tool.closest('.box')
      .find('.box_toolbar').first()
    tool.detach()
    tool.prependTo(box_toolbar)

  # Remove 'edit' buttons for boxes where no .editable element
  # is included.
  #
  this.find('.box_header .edit_button').each ->
    edit_button = $(this)
    box = edit_button.closest('.box')
    edit_button.remove() if box.find('.box_content').find('.editable,.show_only_in_edit_mode,.best_in_place').length == 0

$(document).ready ->
  $(document).process_box_tools()

$(document).on 'mouseenter', '.edit_button', ->
  $(this).closest('.box').find('.archive_button').show('fade')
  $(this).closest('.box').find('.show_activities_button').show('fade')
  $(this).closest('.box').find('.manage_attachments_button').show('fade')

$(document).on 'mouseleave', '.box_header', ->
  $(this).find('.archive_button').hide('fade')
  $(this).find('.show_activities_button').hide('fade')
  $(this).find('.manage_attachments_button').hide('fade')