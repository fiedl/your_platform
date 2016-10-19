# This handles uploading images by dropping them into a text field
# when editing pages.
#
# https://github.com/Rovak/InlineAttachment
#
$(document).on 'edit', '.page_body', ->
  page_body = $(this)
  upload_url = page_body.data('upload-url')
  setTimeout ->
    page_body.find('.best_in_place textarea').inlineattachment
      uploadUrl: upload_url
      extraParams: {inline_attachment: true}
      jsonFieldName: "file_path"
  , 200
