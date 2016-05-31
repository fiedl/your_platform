class App.Gallery

  root_element: {}
  galleria_instance: {}
  current_image_data: {}
  ready_bindings_done: false

  # Initialize a `Gallery` with a `$('.galleria')` element.
  #
  #     gallery = new App.Gallery($('.galleria:first'))
  #
  constructor: (root_element)->
    @root_element = root_element
    @generate_uniqe_id()
    @initSettings()
    @initTheme()
    @bindGalleriaReady()
    @runGalleria()
    @store_gallery_instance_in_data_attribute()

  find: (selector)->
    @root_element.find(selector)

  # Basic galleria configuration.
  # See: http://galleria.io/docs/options/
  #
  default_galleria_options: {
    imageCrop: 'landscape',
    transition: 'slide',
    initialTransition: 'fade',
    assets: false,  # The images are not serverd as assets but by the attachments controller.
    _toggleInfo: true,
    preload: 0,
    #autoplay: 9000,
    popupLinks: false,
    trueFullscreen: false,
    #carousel: false,
    #swipe: 'auto',
    responsive: true,
    #height: 0.625, # 16:10
    height: 0.5629, # 16:9
    debug: false,
    ## height: $(this).find('img').attr('height')
    lightbox: true,
    carousel: false
  }

  initSettings: ->
    self = this
    Galleria.configure(self.default_galleria_options)

  initTheme: ->
    # Initialize galleria. One has to load a theme here,
    # even if the theme files have already been loaded through
    # the asset pipeline.
    #
    Galleria.loadTheme @root_element.data('theme-js-path')

  runGalleria: ->
    self = this
    Galleria.run(self.unique_id(), self.default_galleria_options)

  store_gallery_instance_in_data_attribute: ->
    @root_element.data('gallery', this)

  bindGalleriaReady: ->
    self = this
    Galleria.ready ->
      # The Galleria.ready is fired several times, since it's bound to
      # each instance, again. Therefore, we need to find out, here, whether
      # to process the following stuff, now.
      #
      if self.root_element and self.find('.galleria-thumbnails').length > 0 and self.root_element.attr('id') == this._target.id

        self.ready_bindings_done = true
        self.galleria_instance = this

        # When loading a gallery image, also update the description
        # shown below the image.
        #
        self.galleria_instance.bind 'loadfinish', (e)->
          if e.galleriaData
            self.current_image_data = e.galleriaData
            self.show_description()

        self.hide_thumbs_or_slideshow()
        self.hide_errors_container()
        self.bind_fullscreen_events()

  has_unique_id: ->
    (@root_element.attr('id') || "").indexOf('ui-id') > -1

  generate_uniqe_id: ->
    @root_element.uniqueId()

  unique_id: ->
    @root_element.uniqueId()
    return "#" + @root_element.attr('id')

  show_description: ->
    self = this
    $.ajax({
      type: 'GET',
      url: self.description_path(),
      success: (result) ->
        self.picture_info_element()
          .hide()
          .replaceWith(result.html).show()
        self.picture_info_element()
          .find('.best_in_place').best_in_place()
        self.picture_info_element().find('.remove_button')
          .removeClass('show_only_in_edit_mode')
          .hide()

        # # These are some tests, maybe needed when thumbnails and
        # # slideshow are shown together.
        # #
        # self.picture_info_element()
        #   .css('position', 'relative')
        #   .css('top', (- self.find('.galleria-thumbnails-container').height() - self.picture_info_element().height() - 10) + "px")
        # self.find('.galleria-thumbnails-container')
        #   .css('top', (self.find('.galleria-thumbnails-container').position().top + self.picture_info_element().height() + 30) + "px")
        # self.find('.galleria-container')
        #   .css('height', (self.find('.galleria-container').height() + self.picture_info_element().height() + 20) + "px")
    })

  # /attachments/123/filename.png
  image_path: ->
    @current_image_data.big

  # Transform the image path into the description json url.
  # /attachments/123/filename.png
  description_path: ->
    @image_path().split("/").slice(0,3).join("/") + "/description.json"

  picture_info_element: ->
    @root_element.parent().find('.picture-info')

  # Hide thumbnail collections with less than a couple of elements,
  # since they only confuse people there.
  #
  hide_thumbs_or_slideshow: ->
    if (@find('.galleria-thumbnails .galleria-image').size() < 6) or (@find('.galleria-container').width() < 350)
      @find('.galleria-thumbnails').hide()
      @find('.galleria-stage').css('bottom', '10px')
      @find('.galleria-container').height (index, height)-> height - 50
    else
      @find('.galleria-thumbnails').show()
      @find('.galleria-stage').remove()
      @picture_info_element().remove()

  # Do not show galleria errors. These are not useful
  # in production.
  #
  hide_errors_container: ->
    $('.galleria-errors').hide()

  bind_fullscreen_events: ->
    self = this

    # Clicking on the thumbnail activates the lightbox.
    #
    @root_element.on 'click', '.galleria-thumbnails .galleria-image img', (e)->
      self.galleria_instance.openLightbox()

    # # Clicking on an gallery image switches to fullscreen mode,
    # # i.e. covers the full browser window.
    # #
    # @root_element.on 'click', '.galleria-container:not(.fullscreen) .galleria-stage img', (e)->
    #   console.log "click"
    #   console.log e
    #
    #   # FIXME: Wenn galleria in den Vollbildmodus geht, ist
    #   # galleria_instance._controls.slides == [].
    #   # Deswegen: "Cannot read property 'image' of undefined"
    #   # Eigentlich sollten in diesem Array aber die Slides gespeichert werden,
    #   # d.h. auch die Bildinformationen. So kann beim Vollbild-Wechsel kein Bild geladen werden.
    #   # Wie ich feststellen muss, sind auch die Optionen nicht richtig für die Instanz
    #   # gespeichert.
    #   #
    #   # Wenn man `$('.galleria:last').data('galleria').enterFullscreen()` ausführt,
    #   # funktioniert alles. Sehr eigenartig.
    #   #
    #   # `$('#ui-id-2').data('gallery').enter_fullscreen_mode()` funktioniert,
    #   # `$('#ui-id-2').data('gallery').leave_fullscreen_mode()` funktioniert nicht.
    #
    #   self.enter_fullscreen_mode()
    #
    #   e.stopPropagation()
    #   e.preventDefault()
    #   return false
    #
    # # Clicking on fullscreen galleria container leaves all fullscreen modes,
    # # just to make sure.
    # #
    # $(document).on 'click', '.galleria-container.fullscreen .galleria-stage img', ->
    #
    #   App.gallery_instances.forEach (gallery_instance)->
    #     gallery_instance.leave_fullscreen_mode()
    #
    # $(document).on 'click', '.galleria-container:not(.fullscreen) .galleria-stage img', ->
    #   $(this).closest('.galleria').data('galleria').enterFullscreen()

  enter_fullscreen_mode: ->
    @galleria_instance.enterFullscreen()

  leave_fullscreen_mode: ->
    @galleria_instance.exitFullscreen()
