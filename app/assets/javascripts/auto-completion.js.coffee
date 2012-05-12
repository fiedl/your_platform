jQuery ->

  split = (val) ->
    val.split /,\s*/
  extractLast = (term) ->
    split(term).pop()

  # Auto-Completion for Users-Select-Box
  auto_complete_input_element = null
  $("input[name='direct_member_titles_string']").live("keydown", (event) ->
    unless autocomplete_input_element
      autocomplete_input_element = $( this )
      $(this).autocomplete
        source: (request, response) ->
          $.getJSON autocomplete_input_element.data('autocomplete-url'),
            term: extractLast(request.term)
          , response

        search: ->
          term = extractLast(@value)
          false  if term.length < 2

        focus: ->
          false

        select: (event, ui) ->
          terms = split(@value)
          terms.pop()
          terms.push ui.item.value
          terms.push ""
          @value = terms.join(", ")
          false

    event.preventDefault()  if event.keyCode is $.ui.keyCode.TAB and $(this).data("autocomplete").menu.active
  )
