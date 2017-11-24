class App.Galleries

  constructor: ->
    App.gallery_instances = []

  # This browses the `root_element` for `$('.galleria')`
  # and binds functionality to them.
  #
  process: (root_element)->
    if root_element.find('.galleria').count() > 0
      root_element.find('.galleria').each (index, galleria_element)->

        jquery_galleria_element = $(galleria_element)
        jquery_galleria_element.uniqueId()
        App.gallery_instances.push new App.Gallery(jquery_galleria_element)

  clean: ->
    for gallery in App.gallery_instances
      gallery.destroy()
    App.gallery_instances = []

App.galleries = new App.Galleries()

$(document).ready ->
  # # Just an idea, yet:
  # App.galleries.clean()
  App.galleries.process($(document))


# The button to remove an image is only to be shown when
# hovering the image description.
#
$(document).on 'mouseenter', '.picture-info', ->
  $(this).find('.remove_button').show()
$(document).on 'mouseleave', '.picture-info', ->
  $(this).find('.remove_button').hide()
