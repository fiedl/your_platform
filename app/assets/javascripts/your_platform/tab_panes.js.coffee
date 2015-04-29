currently_selected_tab = ""

$(document).on 'show.bs.tab', 'a[data-toggle="tab"]', (e)->
  currently_selected_tab = $(e.target).attr('href')

$(document).ready ->
  $('a[href="' + currently_selected_tab + '"]').tab('show')