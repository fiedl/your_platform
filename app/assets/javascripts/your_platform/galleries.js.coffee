class App.Galleries

  constructor: ->
    App.gallery_instances = []

  # This browses the `root_element` for `$('.galleria')`
  # and binds functionality to them.
  #
  process: (root_element)->
    if root_element.find('.galleria').size() > 0
      root_element.find('.galleria').each (index, galleria_element)->
        $(galleria_element).uniqueId()
        App.gallery_instances.push new App.Gallery($(galleria_element))



App.galleries = new App.Galleries()

$(document).ready ->
  App.galleries.process($(document))


# The button to remove an image is only to be shown when
# hovering the image description.
#
$(document).on 'mouseenter', '.picture-title', ->
  $(this).find('.remove_button').show()
$(document).on 'mouseleave', '.picture-title', ->
  $(this).find('.remove_button').hide()
