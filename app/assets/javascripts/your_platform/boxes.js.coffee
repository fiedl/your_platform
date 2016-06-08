$(document).on 'edit', '.box', ->
  # This is needed for css styling.
  $(this).find('.content').addClass 'currently_in_edit_mode'
  App.adjust_box_heights_for $(this).closest('.col')

$(document).on 'save', '.box', ->
  $(this).find('.content').removeClass 'currently_in_edit_mode'
  App.adjust_box_heights_for $(this).closest('.col')

$(document).on 'cancel', '.box', ->
  $(this).find('.content').removeClass 'currently_in_edit_mode'
  App.adjust_box_heights_for $(this).closest('.col')

$(document).ready ->
  $('.content_twoCols_right > div.col-xs-12').each ->
    $(this).find('.box:first').addClass('first')

$(document).ready ->
  $(document).process_box_tools()

$.fn.process_box_tools = ->
  this.find('.box.event .edit_button').hide()
  this.find('.box.event #ics_export').hide()
  this.find('.shown_on_edit_button_hover').hide()
  this.find('.shown_on_box_header_hover').hide()

  this.find('.box .panel-title .tool').each ->
    tool = $(this)
    box_toolbar = tool.closest('.panel-heading')
      .find('span.box_toolbar').first()
    tool.detach()
    tool.prependTo(box_toolbar)

  # If there is a panel-footer added to the content, move it outside
  # the panel-body to display it correctly.
  #
  this.find('.panel-body .panel-footer').each ->
    footer = $(this)
    panel = footer.closest('.panel')
    footer.detach()
    footer.appendTo(panel)

  # Remove 'edit' buttons for boxes where no .editable element
  # is included.
  #
  this.find('.edit_button').each ->
    edit_button = $(this)
    box = edit_button.closest('.box')
    edit_button.remove() if box.find('div.content').find('.editable,.show_only_in_edit_mode,.best_in_place').length == 0
