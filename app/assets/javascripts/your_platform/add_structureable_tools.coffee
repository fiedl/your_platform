$(document).on 'click', '.add-structureable a.add_existing_group', ->
  $(this).closest('.add-structureable').find('.dropdown-toggle, .dropdown-menu, .edit_vertical_nav').hide()

  form = "<form class=\"add_existing_group\" method=\"post\">
    #{I18n.t('add_existing_group_as_sub_group')}:
    <input type=\"text\" name=\"group_id\" id=\"group_id\" class=\"group_id\">
    <input type=\"hidden\" name=\"parent_gid\" class=\"parent_gid\">
    <input type=\"hidden\" name=\"authenticity_token\" class=\"authenticity_token\">
    <a href=\"#\" class=\"cancel\">Abbrechen</a>
    <input type=\"submit\" value=\"Ok\">
  </form>"

  $(this).closest('.add-structureable').append form
  App.process_group_id_fields()
  form = $(this).closest('.add-structureable').find('form.add_existing_group')
  form.attr 'action', $(this).data('url') # which is set in `_add_structureable.html.haml`.
  form.find('input.authenticity_token').val $(this).data('authenticity-token')
  form.find('input.parent_gid').val $('body').data('navable')
  form.find('input.group_name_select').focus()
  false

$(document).on 'click', '.add-structureable a.cancel', ->
  wrapper = $(this).closest('.add-structureable')
  wrapper.find('form.add_existing_group').remove()
  wrapper.find('a.dropdown-toggle').button('reset')
  wrapper.find('.dropdown-toggle, .dropdown-menu, .edit_vertical_nav').show().attr('style', "")
  wrapper.find('a.dropdown-toggle').dropdown('toggle')
  false

$(document).on 'submit', '.add-structureable form', ->
  $(this).find('input[type=submit]').hide()
  $(this).find('a.cancel').hide()
  $(this).append("<div class=\"progress_message\">#{I18n.t('the_existing_group_is_now_being_added_as_sub_group_please_wait')}</div>")

