$(document).ready ->
  
  upload_counter = 0
  upload_done_counter = 0
  
  # This element is inserted by form_for(attachments.build) in the view.
  $('#new_attachment').fileupload
    dataType: "script"
    add: (e, data) ->
      upload_counter += 1
      file = data.files[0]
      data.submit()
    progress: (e, data) ->
      show_uploading()
    done: (e, data) ->
      upload_done_counter += 1
      if upload_done_counter >= upload_counter
        show_success()

  $('.attachment_drop_field').on 'dragover', ->
    $(this).addClass('over')
    $(this).removeClass('success')
    $('p.success').hide()
    $('p.drop_attachments_here').show()
  $('.attachment_drop_field').on 'dragleave', ->
    $(this).removeClass('over')
  $('.attachment_drop_field').on 'drop', ->
    $(this).removeClass('over')
    show_uploading()

  show_uploading = ->
    $('.attachment_drop_field').addClass('uploading')
    $('.attachment_drop_field').removeClass('success')
    $('p.drop_attachments_here').hide()
    $('p.success').hide()
    $('p.uploading').removeClass('hidden').show()
    $('.attachment_drop_field').find('form').hide()
    $('.upload_counter').html("" + upload_done_counter + " / " + upload_counter)
    
  show_success = ->
    if $('.attachment_drop_field').size() > 0
      $('.attachment_drop_field')
        .removeClass('uploading')
        .addClass('success')
      $('p.uploading').hide()
      $('p.success').removeClass('hidden').show()
      Turbolinks.visit location.toString(), change: 'attachments'
      
  
  $(document).on 'click', '.pictures .remove_button', ->
    pictures_box = $(this).closest('.box')
    pictures_box.find('.galleria-image.active').hide('explode')
    pictures_box.find('.picture-info').hide('explode')

# When turbolinks is starting to fetch a page, remove the 
# attachment form in order to avoid double binding of the
# jquery-file-upload mechanism.
#
$(document).on "page:fetch", ->
  $('#new_attachment').remove()
  