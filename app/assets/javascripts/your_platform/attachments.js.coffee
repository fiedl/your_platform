class App.Attachments

  constructor: ->
    App.upload_boxes = []

  # This browses the root_element for $('#attachments')
  # and binds UploadBoxes to them.
  #
  process: (root_element)->
    if root_element.find('#attachments, .attachments').addBack('#attachments').size() > 0
      root_element.find('#attachments, .attachments').addBack('#attachments').each (index, attachments_element)->
        if $(attachments_element).find('#new_attachment').size() > 0
          App.upload_boxes.push new App.UploadBox($(attachments_element))

App.attachments = new App.Attachments()

$(document).ready ->
  App.attachments.process($(document))

$(document).on 'click', '.pictures .remove_button', ->
  pictures_box = $(this).closest('.box')
  pictures_box.find('.galleria-image.active').hide('explode')
  pictures_box.find('.picture-info').hide('explode')

