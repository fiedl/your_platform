class App.Attachments

  constructor: ->
    App.upload_boxes = []

  # This browses the root_element for $('#attachments')
  # and binds UploadBoxes to them.
  #
  process: (root_element)->
    if root_element.find('#attachments, .attachments').addBack('#attachments, .attachments').count() > 0
      root_element.find('#attachments, .attachments').addBack('#attachments, .attachments').each (index, attachments_element)->
        if $(attachments_element).find('#new_attachment').count() > 0
          App.upload_boxes.push new App.UploadBox($(attachments_element))

App.attachments = new App.Attachments()

$(document).ready ->
  App.attachments.process($(document))

$(document).on 'click', '.pictures .remove_button', ->
  pictures_box = $(this).closest('.box')
  pictures_box.find('.galleria-image.active').hide('explode')
  pictures_box.find('.picture-info').hide('explode')

$(document).on 'click', 'table.attachments .remove_button', ->
  $(this).closest('tr').hide 'fade', ->
    $(this).remove()

# Remove empty #attachments divs as they disturb the flex layout.
$(document).ready ->
  $('#attachments:empty').remove()