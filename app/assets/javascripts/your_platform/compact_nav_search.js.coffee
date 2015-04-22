$(document).ready ->
  
  search_box = $('.compact-nav-search-input')
  search_box.css({
    "width": $('#user-menu').position().left - search_box.position().left - 50
  })