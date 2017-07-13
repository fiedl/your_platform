
make_sure_horizontal_nav_fits_in_one_line = ->
  font_size_percentage = 100
  while $('#horizontal_nav ul').height() > $('#horizontal_nav ul li:first').height() * 1.1
    font_size_percentage -= 1
    $('#horizontal_nav').css('font-size', "#{font_size_percentage}%")

$(document).ready ->
  make_sure_horizontal_nav_fits_in_one_line()

$(document).on 'click', '#horizontal_nav ul.nav > li a', ->
  # in order to adjust to loading spinner icon
  setTimeout (-> make_sure_horizontal_nav_fits_in_one_line()), 50