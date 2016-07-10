# For image galleries with lots of images, we use masonry:
# https://github.com/desandro/masonry
#

# https://github.com/desandro/masonry/issues/501#issuecomment-34583942
#
$.fn.masonryImagesReveal = (items) ->
  if this.size > 0
    msnry = this.data('masonry')
    itemSelector = msnry.options.itemSelector
    items.hide()
    @append items
    items.imagesLoaded().progress (imgLoad, image) ->
      item = $(image.img)
      item.show()
      msnry.appended item
      msnry.layout()
      return
  this

$(document).ready ->

  images_html = $('.image_attachment_thumbnails').html()
  $('.image_attachment_thumbnails').html('')

  $('.image_attachment_thumbnails').masonry {
    imtemSelector: 'img',
    percentPosition: true
  }

  $('.image_attachment_thumbnails').masonryImagesReveal $(images_html)

$(document).on 'click', '.image_attachment_thumbnails img', ->
  $(this).toggleClass 'giant', 70, ->
    $(this).closest('.image_attachment_thumbnails').masonry('layout')

    # Idee: Width von Container setzen, sodass dieser gelayoutet werden kann
    # und parallel das Image hochanimiert werden kann.

  false

#$(document).on 'click', '.image_attachment_thumbnails img', ->
#  image_big_url = $(this).data('image-big-url')
#  gallery = $(this).closest('.box').find('.galleria').data('gallery')
#  gallery.show(image_big_url)
#  gallery.open_lightbox()