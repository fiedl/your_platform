# This acts as a helper for our mobile apps.
# See: https://github.com/fiedl/Vademecum

$(document).ready ->
  load_from_partial 'body.mobile.contacts .recent_contacts_partial', 'recent_contacts'

  $('body.mobile.contacts .people_search_results').hide()

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
