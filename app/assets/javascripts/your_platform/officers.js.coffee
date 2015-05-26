$('#add_office').click (e)->
  btn = $(this)
  btn.data('loading-text', btn.text() + " ...")
  btn.button('loading')
  $.ajax({
    type: 'POST',
    url: btn.attr('href'),
    success: (r)->
      btn.button('reset')
      new_element = r.officers_group_entry_html
      $('ul.officer_groups').append(new_element)

      $('.box.officers .content').apply_edit_mode()
      officer_entry = $('.officer_entry').last()
      officer_entry.find('.best_in_place').trigger('edit')
      $('.box.officers .content .show_only_in_edit_mode')
        .show()
        .css('visibility', 'visible')
    }
  )
  e.preventDefault()
  
$(document).on 'click', '#destroy_office', (e)->
  url = $(this).attr('href')
  $(this).closest('.officer_entry').remove()
  $(this).closest('tr').remove()
  $.ajax({
    type: 'DELETE',
    url: url
  })
  e.preventDefault()

$(document).on 'change keyup paste', 'table.officers_by_scope input', ->
  text_field = $(this)
  button = $(this).closest('tr').find('.btn-primary')
  if text_field.val() == ""
    button.hide()
  else
    button.removeClass('hidden').show()
    
$(document).on 'submit', 'table.officers_by_scope form.new_officer_group', ->
  form = $(this)
  if form.find('#officer_group_name').val() != ""
    success_message = 
      '<div class="alert alert-success">' +
      I18n.t('creating_new_office') + 
      '</div>'
    $(success_message)
      .insertAfter(form.hide())
      .hide().show('blind')
  
    