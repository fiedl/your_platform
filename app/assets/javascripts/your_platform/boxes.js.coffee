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

$(document).ready ->
  $(document).process_box_tools()

$.fn.process_box_tools = ->
  this.find('.box.event .edit_button').hide()
  this.find('.box.event #ics_export').hide()
  this.find('.archive_button').hide()

  this.find('.box .panel-title .tool').each ->
    tool = $(this)
    box_toolbar = tool.closest('.panel-heading')
      .find('span.box_toolbar').first()
    tool.detach()
    tool.prependTo(box_toolbar)
    
  # Hide 'edit' buttons for boxes where no .editable element 
  # is included.
  #
  this.find('.edit_button:visible').each ->
    edit_button = $(this)
    box = edit_button.closest('.box')
    edit_button.hide() if box.find('div.content').find('.editable,.show_only_in_edit_mode,.best_in_place').length == 0

  this.find('.box_header_table td.box_toolbar').each ->
    console.log $(this).find('a:visible,button:visible').length
    $(this).remove() if $(this).find('a:visible,button:visible').length == 0