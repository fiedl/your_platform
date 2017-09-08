$(document).ready ->

  # scale down the map for smaller devices
  if $('.group_map').width() < 350
    ratio = 0.7
    $('.group_map_background')
      .width($('.group_map_background').width() * ratio)
      .height($('.group_map_background').height() * ratio)

  map_top_latitude = 56.073419     # 249px ^= 54.881828 - 47.273977; 39px
  map_bottom_latitude = 46.326814
  map_left_longitude = 3.762347    # 42 - 270; 185px ^= 15.056013 - 5.851924; 42px ^= 2,0895769622
  map_right_longitude = 17.294845
  map_width = $('.group_map_background').width()
  map_height = $('.group_map_background').height()
  map_longitude_width = map_right_longitude - map_left_longitude
  map_latitude_height = map_top_latitude - map_bottom_latitude

  App.hide_group_map_items()

  $('.group_map .map_item').each ->
    map_item = $(this)
    if map_item.data('longitude') and map_item.data('latitude')
      map_item.css(
        position: 'absolute',
        left: ((map_item.data('longitude') - map_left_longitude) / map_longitude_width * map_width) + "px",
        top: ((map_top_latitude - map_item.data('latitude')) / map_latitude_height * map_height) + "px"
      )

  App.animate_group_map_items()

App.hide_group_map_items = ->
  $('.group_map .map_item').hide()

App.animate_group_map_items = ->
  counter = 0
  $('.group_map .map_item').each ->
    map_item = $(this)
    counter += 1
    setTimeout (-> map_item.show('puff')), 100 + counter * 50

$(document).on 'mouseenter touchstart', '.group_map .map_item', ->
  map_item = $(this)
  map_item.closest('.group_map').find('.map_item').removeClass('active')
  map_item.switchClass '', 'active', 100, ->
    # After completing the animation, make sure the other items do not have the 'active' class.
    # Otherwise, there could be issues when the user changes map item too quickly.
    map_item.closest('.group_map').find('.map_item').removeClass('active')
    map_item.addClass 'active'
  info_area = map_item.closest('.group_map').find('.info_area')
  info_area.find('.title').html "<a href='#'></a>"
  info_area.find('.title a').attr 'href', map_item.data('title-link-url')
  info_area.find('.title a').text map_item.data('title')
  info_area.find('.address').text map_item.data('address')
  info_area.find('.phone').text map_item.data('phone')
  info_area.find('.website').html "<a href='#'></a>"
  info_area.find('.website a').attr 'href', map_item.data('website')
  info_area.find('.website a').text map_item.data('website')
  info_area.find('.email').html "<a href='#'></a>"
  info_area.find('.email a').attr 'href', "mailto:" + map_item.data('email')
  info_area.find('.email a').text map_item.data('email')

  if map_item.data('image-url')
    gallery = $('.box h1:contains(Wohnen)').closest('.box').find('.galleria').data('gallery')
    slides = gallery.galleria_instance._data
    slide_to_show = slides.filter((slide) -> map_item.data('image-url').indexOf(slide.big) > -1).first()
    if slide_to_show
      slide_index = slides.indexOf(slide_to_show)
      gallery.galleria_instance.setOptions('transition', 'fade')
      gallery.galleria_instance.show(slide_index)

    #$('.box h1:contains(Wohnen)').closest('.box').find('img').attr 'src', map_item.data('image-url')
    #$('.box h1:contains(Wohnen)').closest('.box').find('a').attr 'href', map_item.data('image-link-url')

$(document).on 'click', '.group_map .map_item', ->
  window.open $(this).data('title-link-url')
