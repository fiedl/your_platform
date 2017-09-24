$(document).on 'click', '.btn.publish_page', ->
  button = $(this)
  App.spinner.show(button)
  button.closest('.box').find('.box_meta .publish_draft').remove()
  $.ajax({
    type: 'Post',
    url: button.attr('href'),
    success: (result) ->
      button.hide('highlight')
      $('.page_published_at').remove()
      App.success button.closest('.box')
    failure: (result) ->
      console.log result
      alert('Es ist etwas schief gegangen. Bitte laden Sie die Seite neu.')
  })
  false

$(document).on 'click', '.box_meta .publish_draft', ->
  publish_button = $(this).closest('.box').find('.btn.publish_page')
  publish_button.click()
  false