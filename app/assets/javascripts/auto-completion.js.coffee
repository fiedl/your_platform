ready = ->
  
  split = (val) ->
    val.split /,\s*/
  extractLast = (term) ->
    split(term).pop()

  # Auto-Completion for Users-Select-Box
  selector_string = "input[name='direct_member_titles_string'], .multiple-users-select-input, .user-select-input"
  
  $( document ).on 'focus', selector_string, ->
    $(this).tooltip {
      title: 'Nachnamen eingeben, warten und dann Person aus Liste auswählen.',
      placement: 'left'
    }
      
  auto_complete_input_element = null
  $( document ).on( 'keydown', selector_string, ->

    unless autocomplete_input_element
      autocomplete_input_element = $( this )

      # Twitter Bootstrap Version:
      # SF, 2013-01-21
      #
      # http://twitter.github.com/bootstrap/javascript.html#typeahead
      #
      # For the moment, this would work with twitter bootstrap's "typeahead" functionality,
      # but only for single value selection. It would not be possible to select multiple users
      # in a kind of tokenized version.
      #
      # This may change, when the tokenized version is finally pulled to bootstrap.
      #
      # http://stackoverflow.com/questions/12662824/twitter-bootstrap-typeahead-multiple-values
      # https://gist.github.com/2411033
      #
      # In the meantime, we will just use the jquery ui tool.
      #
      # $( this ).typeahead( {
      #   ajax: {
      #     url: autocomplete_input_element.data( 'autocomplete-url' ),
      #     method: 'get'
      #   },
      #   display: 'title'
      # } )
      
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
          if autocomplete_input_element.hasClass( "multiple-users-select-input" )
            terms = split(@value)
            terms.pop()
            terms.push ui.item.value
            terms.push ""
            @value = terms.join(", ")
            false
          else
            @value = ui.item.value

      if event and (event.keyCode is $.ui.keyCode.TAB) and $(this).data("autocomplete").menu.active
        event.preventDefault()  
  )

  # issue fix:
  # allow typeahead selection by clicking an item.
  # see: http://stackoverflow.com/questions/14796415/how-to-use-best-in-place-with-twitter-bootstrap/14799698#14799698
  #
  $( document ).on( 'mousedown', 'ul.typeahead', (event) ->
    event.preventDefault()
  )

$(document).ready(ready)
$(document).on('page:load', ready)
