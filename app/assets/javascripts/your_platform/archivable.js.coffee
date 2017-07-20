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
  if boxes.count() > 0
    boxes.hide 'fold', 300, ->
      boxes.remove()

      # We trigger the request manually here in order not to
      # suppress the animation before.
      send_archive_request(url, true)
  else
    send_archive_request(url, true)
    button.append(": Ok.")
    Turbolinks.reload()

  return false

$(document).on 'click', '.unarchive_button', (e)->
  button = $(this)
  url = button.attr('href')
  boxes = button.closest('.page_with_attachments')

  button.effect 'highlight', ->
    send_archive_request(url, false)

    button.hide 'blind'
    if boxes.count() > 0
      boxes.find('.archived_label').hide 'blind'
    else
      $('.archived_label').hide 'blind'
      Turbolinks.reload()

  return false
