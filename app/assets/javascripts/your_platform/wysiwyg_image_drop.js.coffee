# Uploading images via dropping them into the wysihtml box.
#
# The `fileupload` method is provided by
# https://github.com/blueimp/jQuery-File-Upload.
#
$(document).on 'edit', '.page_body', ->
  page_body = $(this)

  setTimeout ->
    selection = page_body.find('.wysihtml-editor')
      .data('editor').composer.selection
    cursor_position = {}
    page_body.closest('.page').find('form.new_attachment').fileupload
      dataType: "json"
      dropZone: page_body.find('.wysihtml-editor')
      add: (e, data) ->
        # https://github.com/blueimp/jQuery-File-Upload/wiki/Options#add
        cursor_position = selection.getBookmark()
        data.process().done(data.submit())
        selection.setBookmark cursor_position
      done: (e, data) ->
        title = data.result.title
        src = data.result.file_path
        selection.setBookmark cursor_position
        selection.insertHTML("![#{title}](#{window.location.origin}#{src})")
      fail: (e, data) ->
        selection.setBookmark cursor_position
        selection.insertHTML I18n.t('upload_failed')
  , 200

# Prevent the default browser action for dropping, i.e. visiting the local file.
#
# See: https://github.com/blueimp/jQuery-File-Upload/wiki/Options#dropzone
#
$(document).bind 'drop dragover', (e)->
  e.preventDefault()
