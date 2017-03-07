# This script makes sure that clicking on a link within a dropdown menu
# closes the dropdown menu, even if the request takes some time.
#
lock_button_and_show_loading = (btn)->
  btn.attr('data-loading-text', '<span class="glyphicon glyphicon-refresh" aria-hidden="true"></span>' + " " + btn.text().trim() + " ...")
  btn.button("loading") # http://stackoverflow.com/questions/14793367/


$(document).on 'click', '.dropdown-menu * a', (event) ->
  $(this).closest('.btn-group').removeClass("open")

  if $(this).closest('.btn-group').hasClass("group_export")
    # The download is started by the browser in parallel. There is no
    # need to deactivate the button.

  else if $(this).closest('.btn-group').hasClass("workflow_triggers")
    $('.workflow_triggers > .btn').each ->
      lock_button_and_show_loading $(this)

  else
    btn = $(this).closest('.btn-group').find('.btn.dropdown-toggle')
    lock_button_and_show_loading btn
