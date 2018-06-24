# The global search field may be used to filter the current content.
#
$(document).on 'keyup', 'header #search, #header_search #query', ->
  query = $(this).val()

  $('.filter-hidden').removeClass('filter-hidden')

  $('.datatable').each ->
    datatable = $(this).DataTable()
    datatable.search(query).draw()

  for str in query.split(" ")
    for selector in [".box", "li", "tbody tr"]
      $(selector).each ->
        element = $(this)
        unless element.text().toUpperCase().indexOf(str.toUpperCase()) >= 0
          element.addClass('filter-hidden')
