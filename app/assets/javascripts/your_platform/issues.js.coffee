$(document).on 'ajax:success', 'table.issues .best_in_place', ->
  container = $(this).closest('tr').find('td:first')
    .find('.description-container')
  container.hide('blind')
  container.text(I18n.t('the_issue_will_be_rechecked_later'))
  container.show('blind')
