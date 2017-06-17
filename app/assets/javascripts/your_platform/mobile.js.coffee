# This acts as a helper for our mobile apps.
# See: https://github.com/fiedl/Vademecum

$(document).ready ->
  transmit_json_response_to_native_app()

  load_from_partial 'body.mobile.contacts .recent_contacts_partial', 'recent_contacts'

  $('body.mobile.contacts .people_search_results').hide()

  bind_people_search_to 'body.mobile.contacts input.people_search'

  $('#blackscreen').hide()

$(document).on 'change', 'body.mobile form input[type="file"]', ->
  url = $(this).closest('form').attr('action')
  form_data = new FormData()
  $.each $(this)[0].files, (i, file)->
    form_data.append("files[]", file)
  $.ajax {
    type: 'POST',
    url: url,
    data: form_data,
    cache: false,
    contentType: false,
    processData: false,
    success: (result)->
      alert("TODO: Display photos below")
  }
  $(this).closest('form')[0].reset()

$(document).on 'click', 'body.mobile ul.thumbs > li > img', ->
  Turbolinks.visit $(this).data('mobile-photo-path')

$(document).ready ->
  $('body.mobile ul.thumbs > li > img').each ->
    img = $(this)
    img.hide()
    img.attr 'src', img.data('src')
    img.on 'load', ->
      img.fadeIn(500)

transmit_json_response_to_native_app = ->
  if $('.json_response').size() > 0
    # See: https://github.com/turbolinks/turbolinks-ios#passing-messages-from-javascript-to-your-application
    webkit.messageHandlers.handle_json_response
      .postMessage $('.json_response').text()

load_from_partial = (selector, partial)->
  if $(selector).size() > 0
    target = $(selector)
    url = "/mobile/partials/#{partial}"
    $.ajax {
      type: 'GET',
      url: url,
      success: (result)->
        $(selector).replaceWith result
        $(selector).hide()
        $(selector).fadeIn()
        $(selector).process()
        bind_links_to_vcf_files_within selector
      failure: (result)->
        target.fadeOut()
        console.log "failed to load mobile partial #{url}"
        console.log result
    }

perform_people_search = (url, query)->
  if query.length > 3
    $.ajax
      type: 'GET',
      url: url,
      data:
        query: query
      success: (result)->
        $('.people_search_results').fadeIn()
        $('.people_search_results_partial').replaceWith result
        bind_links_to_vcf_files_within '.people_search_results_partial'

bind_people_search_to = (target)->
  $(target).on 'keyup paste change', ->
    url = $(target).closest('form').attr('action')
    perform_people_search(url, $(target).val())

App.mobile_perform_people_search = perform_people_search


$(document).on 'click', 'body.mobile .photoswipe > ul.thumbs > li > img', ->

  li = $(this).closest('li')
  photos = $('.photoswipe').data('photos')

  # Process photo information for photoswipe.
  # http://photoswipe.com/documentation/getting-started.html
  items = []
  for photo in photos
    items.push {
      src: photo.file.url,
      msrc: photo.file.medium.url,
      w: photo.width,
      h: photo.height,
      title: "#{photo.title}<br />#{photo.parent_title}<br />#{photo.author_title}"
    }

  options = {
    index: li.index(),
    shareButtons: [
      {id:'download', label:'Foto speichern', url:'{{raw_image_url}}', download:true}
    ]
  }

  photoswipe_gallery = new PhotoSwipe($('.pswp')[0], PhotoSwipeUI_Default, items, options)

  enter_fullscreen()
  photoswipe_gallery.listen 'close', ->
    unless $('.photo_index').size() > 0
      leave_fullscreen()

  $('#blackscreen').show()
  setTimeout ->
    photoswipe_gallery.init()
  , 100
  setTimeout ->
    $('#blackscreen').hide()
  , 200

  return false

enter_fullscreen = ->
  webkit.messageHandlers.navigation.postMessage 'enterFullscreen' if webkit?

leave_fullscreen = ->
  webkit.messageHandlers.navigation.postMessage 'leaveFullscreen' if webkit?
  $('body').removeClass('fullscreen')

$(document).on 'click', 'body.mobile .photo_index .leave_fullscreen', ->
  leave_fullscreen()
  return false

$(document).ready ->
  if $('body.mobile.photos .photo_index').size() > 0
    $('body').addClass('fullscreen')

$(document).on 'click', 'body.mobile .profiler-output', ->
  $('profiler-results').hide()