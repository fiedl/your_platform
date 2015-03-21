ready = ->
  
  upload_counter = 0
  upload_done_counter = 0
  
  # This element is inserted by form_for(attachments.build) in the view.
  $('#new_attachment').fileupload
    dataType: "script"
    add: (e, data) ->
      upload_counter += 1
      file = data.files[0]
      if $('table.attachments').size() > 0
        data.context = $($.parseHTML(tmpl("template-upload", file)))
        # see https://github.com/blueimp/JavaScript-Templates/issues/19
        #$('table.attachments').append(data.context)
        $('table.attachments').first().prepend(data.context)
        data.context.find('.processing').hide()
      data.submit()
    progress: (e, data) ->
      show_image_upload_uploading()
      if data.context
        progress = parseInt(data.loaded / data.total * 100, 10)
        data.context.find('.bar').css('width', progress + '%')
        if progress > 99
          data.context.find('.processing').show()
          data.context.find('.bar').hide()
    done: (e, data) ->
      upload_done_counter += 1
      if upload_done_counter >= upload_counter
        show_image_upload_success()
      data.context.remove()

  $('.image_attachment_drop_field').on 'dragover', ->
    $(this).addClass('over')
    $(this).removeClass('success')
    $('p.success').hide()
    $('p.drop_images_here').show()
  $('.image_attachment_drop_field').on 'dragleave', ->
    $(this).removeClass('over')
  $('.image_attachment_drop_field').on 'drop', ->
    $(this).removeClass('over')
    show_image_upload_uploading()

  show_image_upload_uploading = ->
    $('.image_attachment_drop_field').addClass('uploading')
    $('.image_attachment_drop_field').removeClass('success')
    $('p.drop_images_here').hide()
    $('p.success').hide()
    $('p.uploading').removeClass('hidden').show()
    $('.image_attachment_drop_field').find('form').hide()
    $('.upload_counter').html("" + upload_done_counter + " / " + upload_counter)
    
  show_image_upload_success = ->
    if $('.image_attachment_drop_field').size() > 0
      $('.image_attachment_drop_field')
        .removeClass('uploading')
        .addClass('success')
      $('p.uploading').hide()
      $('p.success').removeClass('hidden').show()
      
  
  $(document).on 'click', '.pictures .remove_button', ->
    pictures_box = $(this).closest('.box')
    pictures_box.find('.galleria-image.active').hide('explode')
    pictures_box.find('.picture-info').hide('explode')

  $(document).bind('dragover', (e) ->
    $('.attachment_global_drop_zone').fadeIn()
  )
  $('.attachment_global_drop_zone').bind('drop dragleave', (e) ->
    $('.attachment_global_drop_zone').fadeOut()
  )
  $(document).bind('mouseout', (e) ->
    $('.attachment_global_drop_zone').fadeOut()
  )

$(document).ready(ready)
