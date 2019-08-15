$(document).on 'edit', '.box', ->
  # This is needed for css styling.
  $(this).find('.box_content').addClass 'currently_in_edit_mode'

$(document).on 'save', '.box', ->
  $(this).find('.box_content').removeClass 'currently_in_edit_mode'

$(document).on 'cancel', '.box', ->
  $(this).find('.box_content').removeClass 'currently_in_edit_mode'

$(document).ready ->
  $("#content_area .box:first").addClass('first jumbotron')

  $('.box_image:not(:has(img))').addClass('empty')

$.fn.process_box_tools = ->
  this.find('.box.event .edit_button').hide()
  this.find('.box.event #ics_export').hide()
  this.find('.shown_on_edit_button_hover').css('visibility', 'hidden')
  this.find('.shown_on_box_header_hover').css('visibility', 'hidden')

  this.find('.box .box_header .tool').each ->
    tool = $(this)
    box_toolbar = tool.closest('.box')
      .find('.box_tools').first()
    tool.detach()
    tool.appendTo(box_toolbar)

  # Remove 'edit' buttons for boxes where no .editable element
  # is included.
  #
  this.find('.box_header .edit_button').each ->
    edit_button = $(this)
    box = edit_button.closest('.box')
    edit_button.remove() if box.find('.box_content').find('.editable:not(.do_not_show_in_edit_mode),.show_only_in_edit_mode,.best_in_place').length == 0

$(document).ready ->
  $(document).process_box_tools()


$(document).on 'edit', '.box.page', ->
  image_box_id = $(this).attr('id').replace('page-', 'page-image-')
  image_box = $("##{image_box_id}")
  image_box.trigger('edit').addClass('edit-mode-modal')

$(document).on 'save', '.box.page', ->
  image_box_id = $(this).attr('id').replace('page-', 'page-image-')
  image_box = $("##{image_box_id}")
  image_box.trigger('save').removeClass('edit-mode-modal')

$(document).on 'cancel', '.box.page', ->
  image_box_id = $(this).attr('id').replace('page-', 'page-image-')
  image_box = $("##{image_box_id}")
  image_box.trigger('cancel').removeClass('edit-mode-modal')

