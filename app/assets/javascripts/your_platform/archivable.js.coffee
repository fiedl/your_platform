send_archive_request = (url, true_or_false)->
  $.ajax({
    type: 'PUT',
    url: url,
    data: {
      archived: true_or_false
    },
    #success: (result) -> # nothing to do
    failure: (result) ->
      alert('Es ist etwas schief gegangen. Bitte laden Sie die Seite neu.')
  })

$(document).on 'click', '.archive_button', (e)->
  button = $(this)
  url = button.attr('href')
  boxes = button.closest('.page_with_attachments')

  button.effect('highlight')
  boxes.hide 'fold', 300, ->
    boxes.remove()

    # We trigger the request manually here in order not to
    # suppress the animation before.
    send_archive_request(url, true)

  return false

$(document).on 'click', '.unarchive_button', (e)->
  button = $(this)
  url = button.attr('href')
  boxes = button.closest('.page_with_attachments')

  button.effect 'highlight', ->
    send_archive_request(url, false)

    boxes.find('.archived_label').hide 'blind'
    button.hide 'blind'

  return false

$(document).on 'mouseenter', '.edit_button', ->
  $(this).closest('.box').find('.archive_button').show('fade')

$(document).on 'mouseleave', '.box_header', ->
  $(this).find('.archive_button').hide('fade')