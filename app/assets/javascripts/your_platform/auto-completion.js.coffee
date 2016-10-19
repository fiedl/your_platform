# This file handles autocompletion with jQuery Autocomplete:
# https://jqueryui.com/autocomplete

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

# Common Functionality
# -------------------------------------------------------------------------

split = (val) ->
  val.split /,\s*/

extractLast = (term) ->
  split(term).pop()

$.fn.autocomplete_multiple = (args)->
  $.extend args, {
    search: ->
      term = extractLast(@value)
      false if term.length < 2

    focus: ->
      false

    select: (event, ui) ->
      terms = split(@value)
      terms.pop()
      terms.push ui.item.value
      terms.push ""
      @value = terms.join(", ")
      false
  }
  $(this).autocomplete(args)


# Company Name Auto-Completion in users#show
# -------------------------------------------------------------------------
$(document).on 'keydown', 'input.autocomplete.user-select-corporation', ->
  $(this).autocomplete
    source: $(this).data('autocomplete-url')


# Auto-Completion for Users-Select-Box
# -------------------------------------------------------------------------
selector_string = "input[name='direct_member_titles_string'], .multiple-users-select-input, .user-select-input"

$(document).on 'focus', selector_string, ->
  $(this).tooltip
    title: 'Nachnamen eingeben, warten und dann Person aus Liste auswählen.',
    placement: 'left'

$(document).on 'keydown', "input[name='direct_member_titles_string'],  .multiple-users-select-input", ->
  autocomplete_input_element = $(this)

  $(this).autocomplete_multiple
    source: (request, response) ->
      $.getJSON autocomplete_input_element.data('autocomplete-url'),
        term: extractLast(request.term)
      , response

$(document).on 'keydown', ".user-select-input", ->
  autocomplete_input_element = $(this)

  $(this).autocomplete
    source: (request, response) ->
      $.getJSON autocomplete_input_element.data('autocomplete-url'),
        term: request.term
      , response


# Tag lists
# -------------------------------------------------------------------------
$(document).on 'keydown', '.best_in_place.tag_list input', ->
  availableTags = $('.best_in_place.tag_list').data('available-tags')
  $(this).autocomplete_multiple
    source: (request, response) ->
      # delegate back to autocomplete, but extract the last term
      # https://jqueryui.com/autocomplete/#multiple
      response($.ui.autocomplete.filter(availableTags, extractLast(request.term)))


# 2016-10-19: Is this needed in the keydown event? TODO
#
#       if event and (event.keyCode is $.ui.keyCode.TAB) and $(this).data("autocomplete").menu.active
#         event.preventDefault()
#   )
#
