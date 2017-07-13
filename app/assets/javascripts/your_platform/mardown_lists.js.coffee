$(document).ready ->
  $('.page_body ul li').each ->
    li = $(this)
    if (!isNaN(parseInt(li.text(), 10)))
      li.addClass 'no_bullet'
