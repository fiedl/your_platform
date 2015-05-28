$(document).on 'ajax:success', 'table.issues .best_in_place', ->
  container = $(this).closest('tr').find('td:first')
    .find('.description-container')
  container.fadeOut ->
    container.text(I18n.t('the_issue_will_be_rechecked_later'))
    container.fadeIn()

    # # This did not work. TODO: Fix this:
    # setTimeout ->
    #   container.closest('tr').find('td').fadeTo(0.4)
    # , 2000

$(document).on 'click', '#rescan.btn', ->
  $(this).hide().after('<span class="glyphicon glyphicon-refresh"></span> ' + I18n.t('rescanning_issues_please_wait'))