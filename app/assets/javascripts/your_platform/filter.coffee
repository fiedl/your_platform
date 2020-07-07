# The global search field may be used to filter the current content.
#
$(document).on 'keyup', 'header #search, #header_search #query.find_and_filter', ->
  query = $(this).val()

  $('.filter-hidden').removeClass('filter-hidden')

  $('.datatable').each ->
    datatable = $(this).DataTable()
    datatable.search(query).draw()

  for str in query.split(" ")
    for selector in [".box", "li", "tbody tr", ".filterable"]
      $("#content " + selector).each ->
        element = $(this)
        unless element.text().toUpperCase().indexOf(str.toUpperCase()) >= 0
          element.addClass('filter-hidden')

# TODO: Remove this after the feature switch is obsolte.
#
$(document).ready ->
  if $('input.search-query.find_and_filter').count() == 0
    # This feature is still deactivated.
    # Rename the placeholder from "find and filter" to "find".
    $('input.search-query').attr('placeholder', I18n.t('search'))