ready = ->
  
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
    $.ajax({
      type: 'DELETE',
      url: url
    })
    e.preventDefault()
    
$(document).ready(ready)

