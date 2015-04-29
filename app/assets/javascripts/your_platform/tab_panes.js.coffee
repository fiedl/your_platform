currently_selected_user_tab = ""
currently_selected_group_tab = ""

$(document).on 'show.bs.tab', '.nav-tabs.user a[data-toggle="tab"]', (e)->
  currently_selected_user_tab = $(e.target).attr('href')

$(document).on 'show.bs.tab', '.nav-tabs.group a[data-toggle="tab"]', (e)->
  currently_selected_group_tab = $(e.target).attr('href')

$(document).ready ->
  $('.nav-tabs.user a[href="' + currently_selected_user_tab + '"]').tab('show')
  $('.nav-tabs.group a[href="' + currently_selected_group_tab + '"]').tab('show')