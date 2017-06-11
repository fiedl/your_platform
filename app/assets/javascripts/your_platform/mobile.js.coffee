# This acts as a helper for our mobile apps.
# See: https://github.com/fiedl/Vademecum

$(document).ready ->
  transmit_json_response_to_native_app()

  load_from_partial 'body.mobile.contacts .recent_contacts_partial', 'recent_contacts'

  $('body.mobile.contacts .people_search_results').hide()

  bind_people_search_to 'body.mobile.contacts input.people_search'


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