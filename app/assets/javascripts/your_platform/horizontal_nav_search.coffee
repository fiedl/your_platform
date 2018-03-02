switch_to_search = ->
  $('#horizontal_nav > ul').hide()
  $('#horizontal_nav_search').show()
  $('#horizontal_nav_search input#query').focus()

switch_to_nav = ->
  $('#horizontal_nav_search').hide()
  $('#horizontal_nav_search input#query').val('')
  $('#horizontal_nav > ul').show()

$(document).ready ->
  $('#horizontal_nav_search').hide()

$(document).on 'click', '#horizontal_nav .horizontal-nav-search-link a', ->
  switch_to_search()
  false

$(document).on 'click', '#horizontal_nav_search', ->
  false

$(document).on 'click', 'body', ->
  if $('#horizontal_nav_search').is(':visible')
    switch_to_nav()

$(document).on 'keydown', '#horizontal_nav_search input#query', (e)->
  if e.keyCode == 27 # escape
    switch_to_nav()