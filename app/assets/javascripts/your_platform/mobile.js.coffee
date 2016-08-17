# This acts as a helper for our mobile apps.
# See: https://github.com/fiedl/Vademecum

$(document).ready ->
  load_from_partial 'body.mobile.dashboard .events_list_partial', 'events'
  load_from_partial 'body.mobile.contacts .recent_contacts_partial', 'recent_contacts'

  $('body.mobile.contacts .people_search_results').hide()

  bind_links_to_vcf_files_within 'body.mobile'
  bind_people_search_to 'body.mobile.contacts input.people_search'


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

# We have to modify the links to vcf files such that the files
# will not be downloded but opened embedded.
#
bind_links_to_vcf_files_within = (target)->
  $(target).find('.vcf_link').off('click')
  $(target).find('.vcf_link').click (event)->
    url = $(this).attr('href')

    # Now, we have a problem. If we do nothing here or simply call
    #
    #     Turbolinks.visit url
    #
    # then turbolinks will see that the extension is "vcf" and
    # refuse to go through the regular turbolinks process. It will
    # just set the `window.location` and not send anything to the
    # hybrid app adapter.
    #
    # Therefore, we have to send the `visitProposed` ourselves
    # in order to have the mobile app know about this click
    # and the proposed url.
    #
    #     Turbolinks.controller.adapter
    #       .postMessage "visitProposed", {
    #         location: url,
    #         action: "advance"
    #       }
    #
    # This would work. But actually, we could do more and send the
    # vcf content with a separate message. This way, the app does not
    # need to send a separate request, authenticate and download the
    # file.
    #
    if webkit?
      $.get url, (vcf_data)->
        webkit.messageHandlers.display_vcf_data.postMessage vcf_data

      event.stopPropagation()
      event.preventDefault()
      false

bind_people_search_to = (target)->
  $(target).on 'keyup paste change', ->
    if $(target).val().length > 3
      url = $(target).closest('form').attr('action')
      $.ajax
        type: 'GET',
        url: url,
        data:
          query: $(target).val()
        success: (result)->
          $('.people_search_results').fadeIn()
          $('.people_search_results_partial').replaceWith result
          bind_links_to_vcf_files_within '.people_search_results_partial'
