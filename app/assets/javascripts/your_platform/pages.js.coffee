$(document).ready ->
  $('a.destroy_page').off 'click'
  $('a.destroy_page').on 'click', (e)->

    destroy_button = $(this)
    href = destroy_button.attr('href')
    box = destroy_button.closest('.box')
    is_blog_entry = (box.closest('#blog_entries').count() > 0)

    box.trigger 'cancel'
    box.hide 'explode', 300, ->
      box.remove()

      # We trigger the request manually here in order not to
      # suppress the animation before.
      $.ajax({
        type: 'DELETE',
        url: href,
        success: (result) ->
          # If this is just a blog post, we don't need redirection.
          # If the current navable (Page) is destroyed, we need to redirect.
          Turbolinks.visit result.redirect_to unless is_blog_entry
        error: (result) ->
          alert('Es ist etwas schief gegangen. Bitte laden Sie die Seite neu.')
      })

    return false

  if $('#page_settings_button') and $('#toolbar').count() > 0
    $('#page_settings_button').detach().appendTo($('#toolbar'))

# Edit on click when there is no content, yet,
# i.e. for new pages.
#
# When a page content is already present, we don't want this
# to avoid accidental edits and triggering edits when copy/pasting.
#
$(document).on 'click', '.page_body', ->
  if $(this).find('.best_in_place.editable').count() > 0
    if $(this).find('.best_in_place.editable').text().length < 5
      $(this).closest('.box').trigger('edit')