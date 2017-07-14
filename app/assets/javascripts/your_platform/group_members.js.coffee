$(document).on 'change keyup paste', '.dataTables_filter input', ->
  if $('.google_maps')
    $('.google_maps').data('GoogleMap').reload_markers()

$(document).ready ->
  $('.add_group_member_tools').hide()

$(document).on 'change keyup paste', '.add_group_members .user-select-input', ->
  if $(this).val() != ""
    $('.add_group_member_tools').show()
  else
    $('.add_group_member_tools').hide()

$(document).on 'submit', '.add_group_members form.new_membership', (event)->
  form = $(this)
  event.preventDefault()
  event.stopPropagation()

  unless $('.box.members .box_content .alert').size() > 0
    $('.box.members .box_content')
        .prepend("<div class='alert alert-success'>#{I18n.t('member_is_added_in_the_background')}</div>")

  $.ajax {
    url: form.attr('action')
    method: 'post'
    data: form.serialize()
    success: (result)->
      $('.box.members .box_content .alert').remove()
      $('table.members').html result.group_members_table_html
      $('.members_count').remove()
    error: (jqXHR, textStatus, errorThrown)->
      $('.box.members .box_content .alert').remove()
      $('.box.members .box_content')
          .prepend("<div class='alert alert-warning'>#{I18n.t('adding_member_did_not_work')}: #{jqXHR.responseText.truncate(100)}</div>")
  }

  setTimeout ->
    name_field = $('.user-select-input.new-membership')
    name_field.val('')
    name_field.focus()
    $('.add_group_member_tools').hide()
  , 200

