currently_selected_user_tab = ""
currently_selected_group_tab = ""

$(document).on 'show.bs.tab', '.nav-tabs.user a', (e)->
  currently_selected_user_tab = this.hash

$(document).on 'show.bs.tab', '.nav-tabs.group a', (e)->
  currently_selected_group_tab = this.hash

$(document).ready ->
  $('.nav-tabs.user a[href*="' + (location.hash || currently_selected_user_tab) + '"]').tab('show')
  $('.nav-tabs.group a[href*="' + (location.hash || currently_selected_group_tab) + '"]').tab('show')
  
$(document).on 'click', 'ul.nav-tabs.group a', ->
  $(this).tab('show')