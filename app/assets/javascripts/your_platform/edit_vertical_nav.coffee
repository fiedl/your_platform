$(document).on 'click', '.edit_vertical_nav', ->

  # Deactivate edit mode
  if $('#vertical_nav .remove_button').length > 0
    $('#vertical_nav .remove_button').remove()

  # Activate edit mode
  else
    $('#vertical_nav li.child').each ->
      remove_button = "
        <a class=\"remove_button\" title=\"#{I18n.t('vertical_nav_remove_button')}\"><span class=\"glyphicon glyphicon-trash\"></span></a>
      "
      $(this).prepend(remove_button)
$(document).on 'click', '#vertical_nav .remove_button', ->
  li = $(this).closest('li')
  li.find('.remove_button, .move_handle').remove()
  url = "/structureables/sub_entries/destroy"
  data = {
    object_gid: li.find('a').data('navable-gid'),
    parent_gid: $('body').data('navable')
  }
  li.find('a').addClass('being_removed')
  $.ajax {
    type: 'DELETE',
    url: url,
    data: data,
    success: (result)->
      li.remove()
    error: (jqXHR, textStatus, errorThrown)->
      li.find('a').addClass('error').removeClass('being_removed')
  }
