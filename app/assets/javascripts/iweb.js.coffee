
make_sure_horizontal_nav_fits_in_one_line = ->
  if $('#horizontal_nav ul').is(":visible")
    font_size_percentage = 100
    while $('#horizontal_nav ul').height() > $('#horizontal_nav ul li:first').height() * 1.1
      font_size_percentage -= 1
      $('#horizontal_nav').css('font-size', "#{font_size_percentage}%")

$(document).ready ->
  make_sure_horizontal_nav_fits_in_one_line()

$(document).on 'click', '#horizontal_nav ul.nav > li a', ->
  # in order to adjust to loading spinner icon
  setTimeout (-> make_sure_horizontal_nav_fits_in_one_line()), 50


$(document).ready ->
  if $('body').hasClass('iweb-layout')

    # Column layout
    App.permitted_bootstrap_column_classes = [
      'col-sm-12', 'col-sm-8', 'col-sm-4', 'col-sm-6'
    ]

    # Boxes
    $('.box').removeClass('panel panel-default')
    $('.box_header').removeClass('panel-heading')
    $('.box_title')
    $('.box_image')
    $('.box_meta')
    $('.box_content').removeClass('panel-body')
    $('.box_footer').removeClass('panel-footer')
